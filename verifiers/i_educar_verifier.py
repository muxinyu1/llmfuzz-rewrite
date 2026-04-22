from typing import override

from pydantic import BaseModel, Field

from verifier import Verifier


class IEduVerifier(Verifier, BaseModel):

    # 接受数据库请求的端口
    on_call_port: int = Field(default_factory=int)
    

    @classmethod
    def build(cls) -> IEduVerifier:
        return IEduVerifier()

    @override
    def check(self) -> bool:
        # TODO 检查on_call_port是否接收到了来自agent写的SQL语句在数据库执行之后由数据库发来的请求
        return super().check()
