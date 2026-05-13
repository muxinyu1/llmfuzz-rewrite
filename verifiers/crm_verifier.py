from __future__ import annotations

from datetime import datetime, timedelta, timezone
import re
import subprocess
import threading
from http.server import ThreadingHTTPServer
from typing import List

from pydantic import BaseModel, Field, PrivateAttr

from verifier import Verifier


class CRMVerifier(Verifier, BaseModel):

    # Port used for callback requests from the database.
    on_call_port: int = Field(default_factory=int)
    # Captured payload values from callback requests.
    buffer: List[str] = Field(default_factory=list)
    ground_truth: List[str] = Field(default_factory=list)

    _server: ThreadingHTTPServer | None = PrivateAttr(default=None)
    _server_thread: threading.Thread | None = PrivateAttr(default=None)
    _buffer_lock: threading.Lock = PrivateAttr(default_factory=threading.Lock)
    _callback_events: list[tuple[str, datetime]] = PrivateAttr(default_factory=list)

    @classmethod
    def build(
        cls,
        on_call_port: int = 8000,
        ground_truth: List[str] | None = None,
    ) -> CRMVerifier:
        if ground_truth is None:
            ground_truth = ["crm0", "crm1", "crm2", "crm3", "crm4", "crm5"]

        crm = CRMVerifier(
            on_call_port=on_call_port,
            ground_truth=ground_truth,
        )
        crm._listen()
        return crm

    def _append_payloads(self, payloads: list[str]):
        self._ensure_runtime_attrs()
        now = datetime.now(timezone.utc)
        with self._buffer_lock:
            self.buffer.extend(payloads)
            for payload in payloads:
                self._callback_events.append((payload, now))

    def _check(self) -> bool:
        if not super()._check():
            return False

        provenance_ok = self._validate_callback_origin_from_request_timeline()
        if not provenance_ok:
            print(
                "[crm verifier] callback provenance validation failed: "
                "token must align with its mapped CRM endpoint",
                flush=True,
            )
        return provenance_ok

    def _validate_callback_origin_from_request_timeline(self) -> bool:
        token_expected_route: dict[str, str] = {
            "crm0": "/usereditor.php",
            "crm1": "/listevents.php",
            "crm2": "/egive.php",
            "crm3": "/eventeditor.php",
            "crm4": "/eventeditor.php",
            "crm5": "/editeventtypes.php",
        }

        unknown_tokens = [
            token for token in self.ground_truth if token not in token_expected_route
        ]
        if unknown_tokens:
            print(
                f"[crm verifier] unsupported ground truth tokens for provenance checks: {unknown_tokens}",
                flush=True,
            )
            return False

        callback_time_by_token = self._first_callback_time_by_token()
        missing_tokens = [
            token for token in self.ground_truth if token not in callback_time_by_token
        ]
        if missing_tokens:
            print(
                f"[crm verifier] missing callback timestamps for tokens: {missing_tokens}",
                flush=True,
            )
            return False

        request_events = self._collect_crm_request_events()
        if not request_events:
            print(
                "[crm verifier] no CRM request timeline found in app logs for provenance checks",
                flush=True,
            )
            return False

        max_lag = timedelta(seconds=20)
        used_request_indices: set[int] = set()

        for token in self.ground_truth:
            expected_route = token_expected_route[token]
            callback_at = callback_time_by_token[token]

            best_idx: int | None = None
            best_lag: timedelta | None = None

            for idx, (request_at, request_path) in enumerate(request_events):
                if idx in used_request_indices:
                    continue
                if request_path != expected_route:
                    continue

                lag = callback_at - request_at
                if lag.total_seconds() < 0 or lag > max_lag:
                    continue

                if best_lag is None or lag < best_lag:
                    best_lag = lag
                    best_idx = idx

            if best_idx is None:
                print(
                    f"[crm verifier] token '{token}' has no matching {expected_route} request within {max_lag.total_seconds():.0f}s",
                    flush=True,
                )
                return False

            used_request_indices.add(best_idx)

        return True

    def _first_callback_time_by_token(self) -> dict[str, datetime]:
        self._ensure_runtime_attrs()
        with self._buffer_lock:
            events = list(self._callback_events)

        seen: dict[str, datetime] = {}
        targets = set(self.ground_truth)
        for payload, event_time in events:
            if payload in targets and payload not in seen:
                seen[payload] = event_time
        return seen

    def _collect_crm_request_events(self) -> list[tuple[datetime, str]]:
        try:
            container_id = self._find_crm_web_container_id()
            if not container_id:
                return []

            app_logs_proc = subprocess.run(
                [
                    "docker",
                    "exec",
                    container_id,
                    "sh",
                    "-lc",
                    "log_file=$(ls -1t /var/www/html/logs/*-app.log 2>/dev/null | head -n 1); "
                    "if [ -n \"$log_file\" ]; then tail -n 4000 \"$log_file\"; fi",
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            if app_logs_proc.returncode != 0:
                return []

            request_events: list[tuple[datetime, str]] = []
            for line in app_logs_proc.stdout.splitlines():
                if "bootstrap completed successfully" not in line:
                    continue

                ts_match = re.match(r"^\[(?P<ts>[^\]]+)\]", line)
                url_match = re.search(r'"url":"(?P<url>[^"]+)"', line)
                if ts_match is None or url_match is None:
                    continue

                parsed_ts = self._parse_iso_datetime(ts_match.group("ts"))
                if parsed_ts is None:
                    continue

                request_path = url_match.group("url").split("?", 1)[0].lower()
                request_events.append((parsed_ts, request_path))

            request_events.sort(key=lambda item: item[0])
            return request_events
        except Exception as exc:
            print(f"[crm verifier] failed to collect CRM request timeline: {exc}", flush=True)
            return []

    @staticmethod
    def _parse_iso_datetime(value: str) -> datetime | None:
        try:
            parsed = datetime.fromisoformat(value)
        except ValueError:
            return None

        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed.astimezone(timezone.utc)

    def _find_crm_web_container_id(self) -> str | None:
        exact_project = subprocess.run(
            [
                "docker",
                "ps",
                "--filter",
                "label=com.docker.compose.project=churchcrm-prod-5210",
                "--filter",
                "label=com.docker.compose.service=webserver",
                "--format",
                "{{.ID}}",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        exact_ids = [line.strip() for line in exact_project.stdout.splitlines() if line.strip()]
        if exact_ids:
            return exact_ids[0]

        generic = subprocess.run(
            [
                "docker",
                "ps",
                "--filter",
                "label=com.docker.compose.service=webserver",
                "--format",
                "{{.ID}} {{.Names}}",
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        fallback_id: str | None = None
        for row in generic.stdout.splitlines():
            parts = row.strip().split(maxsplit=1)
            if not parts:
                continue
            candidate_id = parts[0]
            candidate_name = parts[1].lower() if len(parts) > 1 else ""

            if fallback_id is None:
                fallback_id = candidate_id
            if "churchcrm" in candidate_name:
                return candidate_id

        return fallback_id
