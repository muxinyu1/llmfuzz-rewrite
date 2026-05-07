import json
from pathlib import Path

from pydantic import BaseModel, Field


class AppEntry(BaseModel):
    name: str = Field(default_factory=str)
    port: int = Field(default_factory=int)
    start_script: str | None = Field(default=None)


class RuntimeConfig(BaseModel):
    selected_app: str = Field(default="i_educar")
    use_container: bool = Field(default=False)
    verifier_port: int = Field(default=8000, ge=1)
    verifier_host: str = Field(default="host.docker.internal")


class OpenCodeAgentConfig(BaseModel):
    timeout_seconds: int = Field(default=1800, ge=1)
    idle_timeout_seconds: int = Field(default=300, ge=1)
    startup_timeout_seconds: int | None = Field(default=None, ge=1)
    working_dir: str | None = Field(default=None)
    model: str | None = Field(default="paratera/DeepSeek-R1-0528")
    agent_name: str | None = Field(default=None)


class ProjectConfig(BaseModel):
    runtime: RuntimeConfig = Field(default_factory=RuntimeConfig)
    opencode_agent: OpenCodeAgentConfig = Field(default_factory=OpenCodeAgentConfig)
    apps: list[AppEntry] = Field(default_factory=list)



def load_project_config(config_path: str | Path = "apps.json") -> ProjectConfig:
    path = Path(config_path).expanduser().resolve()
    if not path.exists():
        raise FileNotFoundError(f"Project config file not found: {path}")

    raw = json.loads(path.read_text(encoding="utf-8"))

    # Backward compatibility: old apps.json was a plain app list.
    if isinstance(raw, list):
        raw = {"apps": raw}

    # Backward compatibility for previous naming.
    if isinstance(raw, dict) and "opencode" in raw and "opencode_agent" not in raw:
        raw["opencode_agent"] = raw["opencode"]

    return ProjectConfig.model_validate(raw)
