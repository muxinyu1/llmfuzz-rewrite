from __future__ import annotations

import threading
from http.server import ThreadingHTTPServer
from typing import List

from pydantic import BaseModel, Field, PrivateAttr

from verifier import Verifier


class MyLittleForumVerifier(Verifier, BaseModel):

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
    ) -> MyLittleForumVerifier:
        if ground_truth is None:
            ground_truth = ["mylittleforum0"]

        mylittleforum = MyLittleForumVerifier(
            on_call_port=on_call_port,
            ground_truth=ground_truth,
        )
        mylittleforum._listen()
        return mylittleforum