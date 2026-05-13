from __future__ import annotations

import subprocess
import threading
from http.server import ThreadingHTTPServer
from typing import List

from pydantic import BaseModel, Field, PrivateAttr

from verifier import Verifier


class AtomBoardVerifier(Verifier, BaseModel):

    # Port used for callback requests from the target database.
    on_call_port: int = Field(default_factory=int)
    # Captured payload values from callback requests.
    buffer: List[str] = Field(default_factory=list)
    ground_truth: List[str] = Field(default_factory=list)

    _server: ThreadingHTTPServer | None = PrivateAttr(default=None)
    _server_thread: threading.Thread | None = PrivateAttr(default=None)
    _buffer_lock: threading.Lock = PrivateAttr(default_factory=threading.Lock)

    @classmethod
    def build(
        cls,
        on_call_port: int = 8000,
        ground_truth: List[str] | None = None,
    ) -> "AtomBoardVerifier":
        if ground_truth is None:
            ground_truth = [
                "atomboard0",
                "atomboard1",
                "atomboard2",
                "atomboard3",
            ]

        atomboard = AtomBoardVerifier(
            on_call_port=on_call_port,
            ground_truth=ground_truth,
        )
        atomboard._listen()
        return atomboard

    def _check(self) -> bool:
        if not super()._check():
            return False

        provenance_ok = self._validate_callback_origin_from_http_logs()
        if not provenance_ok:
            print(
                "[atomboard verifier] callback provenance validation failed: "
                "token must come from its mapped injection route",
                flush=True,
            )
        return provenance_ok

    def _validate_callback_origin_from_http_logs(self) -> bool:
        request_logs = self._collect_atomboard_request_logs()
        if not request_logs:
            # Strict mode: if we cannot collect request logs, we cannot prove provenance.
            print(
                "[atomboard verifier] no atomboard request logs collected for provenance checks",
                flush=True,
            )
            return False

        token_route_keys: dict[str, str | None] = {
            "atomboard0": "like",
            "atomboard1": "lift",
            "atomboard2": None,
            "atomboard3": None,
        }

        for token, expected_key in token_route_keys.items():
            marker_lines = [
                line
                for line in request_logs
                if any(marker in line for marker in self._token_markers(token))
            ]
            if expected_key is None:
                if marker_lines:
                    print(
                        f"[atomboard verifier] token '{token}' leaked into URL query; "
                        "expected POST-body-only route",
                        flush=True,
                    )
                    return False
                continue

            if not marker_lines:
                print(
                    f"[atomboard verifier] token '{token}' not found in HTTP request logs",
                    flush=True,
                )
                return False

            if not any(f"{expected_key}=" in line for line in marker_lines):
                print(
                    f"[atomboard verifier] token '{token}' was not sent via expected key '{expected_key}'",
                    flush=True,
                )
                return False

            if any(f"{expected_key}=" not in line for line in marker_lines):
                print(
                    f"[atomboard verifier] token '{token}' appeared in a non-{expected_key} request",
                    flush=True,
                )
                return False

        return True

    @staticmethod
    def _token_markers(token: str) -> tuple[str, str]:
        return token.lower(), token.encode("utf-8").hex().lower()

    def _collect_atomboard_request_logs(self) -> list[str]:
        try:
            find_container = subprocess.run(
                [
                    "docker",
                    "ps",
                    "--filter",
                    "label=com.docker.compose.project=atomboard",
                    "--filter",
                    "label=com.docker.compose.service=atomboard",
                    "--format",
                    "{{.ID}}",
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            container_id = find_container.stdout.strip().splitlines()
            if not container_id:
                return []

            logs_proc = subprocess.run(
                ["docker", "logs", "--since", "30m", container_id[0]],
                check=False,
                capture_output=True,
                text=True,
            )

            merged = "\n".join(filter(None, [logs_proc.stdout, logs_proc.stderr]))
            request_lines = [
                line.lower()
                for line in merged.splitlines()
                if "imgboard.php" in line and "http/" in line
            ]
            return request_lines
        except Exception as exc:
            print(f"[atomboard verifier] failed to collect docker logs: {exc}", flush=True)
            return []
