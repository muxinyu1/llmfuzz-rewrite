from __future__ import annotations

import threading
from http.server import ThreadingHTTPServer
from typing import List

from pydantic import BaseModel, Field, PrivateAttr

from verifier import Verifier


class IEduVerifier(Verifier, BaseModel):

    # 接受数据库请求的端口
    on_call_port: int = Field(default_factory=int)
    # 缓存的来自数据库请求的内容
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
    ) -> IEduVerifier:
        if ground_truth is None:
            ground_truth = ["educar0", "educar1", "educar2"]

        educar = IEduVerifier(
            on_call_port=on_call_port,
            ground_truth=ground_truth # educar一共三个漏洞
        )
        educar._listen()
        return educar
