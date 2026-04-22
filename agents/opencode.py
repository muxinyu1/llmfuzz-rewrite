from typing import Any, override

from pydantic import BaseModel

from agent import Agent


class OpenCodeAgent(Agent, BaseModel):

    @override
    def attack(self, args: Any | None):
        # 调用opencode agent subprocess
        