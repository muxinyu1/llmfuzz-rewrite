from abc import ABC, abstractmethod
from typing import Any

from pydantic import BaseModel

from llm import LLM


class Agent(ABC):
    @abstractmethod
    def attack(self, prompt: str):
        pass