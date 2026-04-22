from typing import List

from pydantic import BaseModel, Field


class Container(BaseModel):
    id: str = Field(default_factory=str)
    port: int = Field(default_factory=int)
    app: str = Field(default_factory=str)

class ContainerManager(BaseModel):

    containers: List[Container] # 存活的容器，只考虑

    apps: List[str] # 管理的app名称，例如[i_educar、openstamanager]

