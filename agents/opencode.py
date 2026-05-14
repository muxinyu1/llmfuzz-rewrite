import json
import os
import select
import subprocess
import time
from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import override

from pydantic import BaseModel, Field

from agent import Agent


class OpenCodeAgent(Agent, BaseModel):
    timeout_seconds: int = Field(default=1800, ge=1)
    idle_timeout_seconds: int = Field(default=300, ge=1)
    startup_timeout_seconds: int = Field(default=300, ge=1)
    working_dir: str = Field(
        default_factory=lambda: str(Path(__file__).resolve().parents[1])
    )
    allowed_roots: list[str] = Field(default_factory=list)
    writable_roots: list[str] = Field(default_factory=list)
    model: str | None = Field(default="paratera/DeepSeek-R1-0528")
    agent_name: str | None = Field(default=None)
    last_output: str = Field(default_factory=str)

    def model_post_init(self, __context):
        """Called after model initialization"""
        self.startup_timeout_seconds = max(
            self.startup_timeout_seconds,
            self.idle_timeout_seconds,
            300,
        )
        resolved_working_dir = Path(self.working_dir).expanduser().resolve()
        self.working_dir = str(resolved_working_dir)
        if not self.allowed_roots:
            self.allowed_roots = [self.working_dir]
        else:
            self.allowed_roots = [
                str(Path(root).expanduser().resolve()) for root in self.allowed_roots
            ]

        if not self.writable_roots:
            # Allow writing in sandbox working_dir and /tmp scratch by default.
            self.writable_roots = [self.working_dir, "/tmp"]
        else:
            self.writable_roots = [
                str(Path(root).expanduser().resolve()) for root in self.writable_roots
            ]

    def _is_path_within_roots(self, candidate: Path, roots: list[str]) -> bool:
        for root in roots:
            if candidate.is_relative_to(Path(root)):
                return True
        return False

    def _is_read_path_allowed(self, candidate: Path) -> bool:
        return self._is_path_within_roots(
            candidate,
            [*self.allowed_roots, *self.writable_roots],
        )

    def _is_write_path_allowed(self, candidate: Path) -> bool:
        return self._is_path_within_roots(candidate, self.writable_roots)

    def _to_candidate_path(self, value: str) -> Path | None:
        raw = value.strip()
        if not raw:
            return None

        if raw.startswith(("http://", "https://")):
            return None

        if raw.startswith("file://"):
            raw = raw[7:]

        if any(ch in raw for ch in ["*", "?"]):
            return None

        path = Path(raw)
        # opencode tools may emit sandbox-absolute paths under /workspace.
        # Treat /workspace as an alias of this agent's working_dir so
        # policy checks validate against the local sandbox roots.
        workspace_root = Path("/workspace")
        if path.is_absolute() and (path == workspace_root or workspace_root in path.parents):
            path = Path(self.working_dir) / path.relative_to(workspace_root)

        if not path.is_absolute():
            path = Path(self.working_dir) / path

        return path.expanduser().resolve()

    def _find_forbidden_access(self, event: dict) -> str | None:
        if event.get("type") != "tool_use":
            return None

        part = event.get("part", {})
        state = part.get("state", {})
        state_input = state.get("input")
        if state_input is None:
            return None

        tool = part.get("tool", "<unknown>")
        path_like_tokens = ("path", "file", "dir", "cwd", "uri", "include")
        violations: list[Path] = []
        lowered_tool = tool.lower()
        write_like_tools = {
            "write",
            "edit",
            "patch",
            "create",
            "delete",
            "move",
            "rename",
        }
        is_write_like = any(token in lowered_tool for token in write_like_tools)

        def _walk(node, key_hint: str = ""):
            if isinstance(node, Mapping):
                for k, v in node.items():
                    _walk(v, str(k))
                return

            if isinstance(node, Sequence) and not isinstance(node, (str, bytes, bytearray)):
                for item in node:
                    _walk(item, key_hint)
                return

            if not isinstance(node, str):
                return

            lowered = key_hint.lower()
            if not any(token in lowered for token in path_like_tokens):
                return

            candidate = self._to_candidate_path(node)
            if candidate is None:
                return

            if is_write_like:
                allowed = self._is_write_path_allowed(candidate)
            else:
                allowed = self._is_read_path_allowed(candidate)

            if not allowed:
                violations.append(candidate)

        _walk(state_input)

        if not violations:
            return None

        unique_paths = sorted({str(path) for path in violations})
        if is_write_like:
            return (
                "Forbidden write path detected "
                f"(outside writable roots) via tool '{tool}': "
                + ", ".join(unique_paths)
            )

        return (
            "Forbidden project file access detected "
            f"(outside allowed source roots) via tool '{tool}': "
            + ", ".join(unique_paths)
        )


    @override
    def attack(self, prompt: str):
        message = prompt.strip()
        if not message:
            raise ValueError("attack prompt cannot be empty")

        cmd = [
            "opencode", "run", message,
            "--dir", self.working_dir,
            "--dangerously-skip-permissions",
            "--format", "json",
        ]
        if self.model:
            cmd.extend(["--model", self.model])
        if self.agent_name:
            cmd.extend(["--agent", self.agent_name])

        raw_chunks: list[str] = []
        text_parts: list[str] = []
        tool_summaries: list[str] = []
        error_messages: list[str] = []
        non_json_lines: list[str] = []
        forbidden_reason: str | None = None
        self.last_output = ""

        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )
        except FileNotFoundError as e:
            raise RuntimeError(
                "opencode command not found. Please install it and ensure it is in PATH."
            ) from e

        assert process.stdout is not None
        stdout_fd = process.stdout.fileno()
        start_time = time.monotonic()
        line_buf = ""
        print(
            f"[opencode] started (startup timeout={self.startup_timeout_seconds}s, idle timeout={self.idle_timeout_seconds}s)",
            flush=True,
        )
        print(f"[opencode] pid={process.pid}", flush=True)

        def _parse_line(line: str):
            """Parse a JSON event line and extract text / tool-use content."""
            line = line.strip()
            if not line:
                return
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                non_json_lines.append(line)
                return

            nonlocal forbidden_reason
            if forbidden_reason is None:
                forbidden_reason = self._find_forbidden_access(event)
                if forbidden_reason is not None:
                    print(f"[policy] {forbidden_reason}", flush=True)

            etype = event.get("type")
            if etype == "text":
                text = event.get("part", {}).get("text", "")
                if text:
                    text_parts.append(text)
                    print(text, end="", flush=True)
            elif etype == "step_start":
                summary = "[step] started"
                tool_summaries.append(summary)
                print(summary, flush=True)
            elif etype == "step_finish":
                reason = event.get("part", {}).get("reason", "")
                summary = f"[step] finished ({reason or 'unknown'})"
                tool_summaries.append(summary)
                print(summary, flush=True)
            elif etype == "tool_use":
                part = event.get("part", {})
                tool = part.get("tool", "")
                state = part.get("state", {})
                status = state.get("status", "")
                if status == "completed":
                    title = state.get("title") or tool
                    summary = f"[tool:{tool}] {title}"
                    tool_summaries.append(summary)
                    print(summary, flush=True)
            elif etype == "error":
                error = event.get("error", {})
                message = (
                    error.get("data", {}).get("message")
                    or error.get("message")
                    or error.get("name")
                    or str(error)
                )
                if message:
                    error_messages.append(message)
                    print(f"[opencode-error] {message}", flush=True)

        try:
            last_data_time: float | None = None
            last_heartbeat_time = start_time
            heartbeat_interval_seconds = 15
            while True:
                now = time.monotonic()
                if now - start_time > self.timeout_seconds:
                    process.kill()
                    process.wait()
                    self.last_output = "".join(text_parts)
                    raise RuntimeError(
                        f"opencode run timed out after {self.timeout_seconds}s"
                    )
                if last_data_time is None:
                    if now - start_time > self.startup_timeout_seconds:
                        process.kill()
                        process.wait()
                        self.last_output = "".join(text_parts)
                        raise RuntimeError(
                            "opencode run startup timed out "
                            f"(no initial output for {self.startup_timeout_seconds}s)"
                        )
                elif now - last_data_time > self.idle_timeout_seconds:
                    process.kill()
                    process.wait()
                    self.last_output = "".join(text_parts)
                    raise RuntimeError(
                        f"opencode run idle timed out (no output for {self.idle_timeout_seconds}s)"
                    )

                if now - last_heartbeat_time >= heartbeat_interval_seconds:
                    elapsed = int(now - start_time)
                    if last_data_time is None:
                        print(
                            f"[opencode] waiting for first output... elapsed={elapsed}s pid={process.pid}",
                            flush=True,
                        )
                    else:
                        idle_for = int(now - last_data_time)
                        print(
                            f"[opencode] waiting for next output... idle={idle_for}s elapsed={elapsed}s pid={process.pid}",
                            flush=True,
                        )
                    last_heartbeat_time = now

                ready, _, _ = select.select([stdout_fd], [], [], 0.2)
                if ready:
                    data = os.read(stdout_fd, 4096)
                    if data:
                        last_data_time = time.monotonic()
                        chunk = data.decode(errors="replace")
                        raw_chunks.append(chunk)
                        line_buf += chunk
                        while "\n" in line_buf:
                            line, line_buf = line_buf.split("\n", 1)
                            _parse_line(line)
                            if forbidden_reason is not None:
                                process.kill()
                                process.wait()
                                raise RuntimeError(forbidden_reason)
                        continue

                if process.poll() is not None:
                    break

            # flush remaining buffer
            if line_buf:
                _parse_line(line_buf)
                if forbidden_reason is not None:
                    process.kill()
                    process.wait()
                    raise RuntimeError(forbidden_reason)
        finally:
            if forbidden_reason is not None:
                self.last_output = f"ACCESS_VIOLATION: {forbidden_reason}"
            elif text_parts:
                self.last_output = "".join(text_parts)
            elif error_messages:
                self.last_output = "\n".join(f"ERROR: {m}" for m in error_messages)
            elif tool_summaries:
                self.last_output = "\n".join(tool_summaries)
            elif non_json_lines:
                self.last_output = "\n".join(non_json_lines[-20:])
            else:
                self.last_output = ""

        if error_messages:
            raise RuntimeError(
                "opencode run returned error event(s): "
                + " | ".join(error_messages)
            )

        if process.returncode != 0:
            detail = "".join(raw_chunks).strip()
            raise RuntimeError(f"opencode run failed: {detail}")