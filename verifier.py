from abc import ABC, abstractmethod
from typing import Any

from pydantic import BaseModel

from agent import Agent


class Verifier(ABC):
    def verify(self, agent: Agent, args: Any | None) -> bool:
        agent.attack(args)
        if self.check():
            return True
        return False

    @abstractmethod
    def check(self) -> bool:
        pass