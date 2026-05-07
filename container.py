import json
import subprocess
from pathlib import Path
from typing import List, Optional, Tuple

from pydantic import BaseModel, Field


class Container(BaseModel):
    id: str = Field(default_factory=str)
    port: int = Field(default_factory=int)
    app: str = Field(default_factory=str)

class App(BaseModel):
    name: str = Field(default_factory=str)
    port: int = Field(default_factory=int)
    start_script: Optional[str] = Field(default=None)

class ContainerManager(BaseModel):

    containers: List[Container] = Field(default_factory=list) # 存活的容器，只考虑

    apps: List[App] = Field(default_factory=list) # 管理的app列表，

    @classmethod
    def build(cls, app_config: str) -> "ContainerManager":
        config_path = Path(app_config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"App config not found: {config_path}")

        raw = json.loads(config_path.read_text(encoding="utf-8"))
        if isinstance(raw, dict):
            raw_apps = raw.get("apps", [])
        elif isinstance(raw, list):
            raw_apps = raw
        else:
            raise ValueError("App config must be a list or an object containing 'apps'.")

        apps = [App.model_validate(item) for item in raw_apps]
        return cls(apps=apps)

    def _find_app(self, app: str) -> App | None:
        for item in self.apps:
            if item.name == app:
                return item
        return None

    def _project_root(self) -> Path:
        return Path(__file__).resolve().parent

    def _ensure_apps_loaded(self):
        if self.apps:
            return

        default_config = self._project_root() / "apps.json"
        if default_config.exists():
            self.apps = self.build(str(default_config)).apps

    def _resolve_compose_file(self, app: str) -> Path:
        root = self._project_root()
        candidates = [
            root / "examples" / app / "compose.yaml",
            root / "examples" / app / "compose.yml",
            root / "sources" / app / "docker-compose.yml",
            root / "sources" / app / "docker-compose.yaml",
            root / "sources" / app / "docker-compose.full.yml",
            root / "sources" / app / "docker-compose.full.yaml",
        ]

        for path in candidates:
            if path.exists() and path.is_file() and path.stat().st_size > 0:
                return path

        raise FileNotFoundError(
            "No usable compose file found for app "
            f"'{app}'. Checked: {', '.join(str(p) for p in candidates)}"
        )

    def _run_cmd(self, args: list[str]) -> str:
        result = subprocess.run(
            args,
            check=True,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()

    def _compose_cmd(self, compose_file: Path, *compose_args: str) -> list[str]:
        return [
            "docker",
            "compose",
            "-f",
            str(compose_file),
            *compose_args,
        ]

    def _resolve_container_id(self, compose_file: Path) -> str:
        output = self._run_cmd(self._compose_cmd(compose_file, "ps", "-q"))
        for line in output.splitlines():
            cid = line.strip()
            if cid:
                return cid
        return ""

    def new_container(
        self,
        app: str,
        verifier_port: int | None = None,
        verifier_host: str | None = None,
    ) -> Tuple[str, int]:
        self._ensure_apps_loaded()

        app_conf = self._find_app(app)
        if app_conf is None:
            raise ValueError(f"Unknown app: {app}")

        for c in self.containers:
            if c.app == app:
                return c.app, c.port

        if app_conf.start_script:
            script_path = (self._project_root() / app_conf.start_script).resolve()
            if not script_path.exists():
                raise FileNotFoundError(f"start_script not found: {script_path}")
            cmd = ["bash", str(script_path)]
            if verifier_port is not None:
                cmd.extend(["--verifier-port", str(verifier_port)])
            if verifier_host:
                cmd.extend(["--verifier-host", verifier_host])
            try:
                subprocess.run(
                    cmd,
                    check=True,
                )
            except subprocess.CalledProcessError as e:
                raise RuntimeError(
                    f"start_script failed for app '{app}' (exit {e.returncode})"
                ) from e
        else:
            compose_file = self._resolve_compose_file(app)
            try:
                self._run_cmd(self._compose_cmd(compose_file, "up", "-d"))
            except subprocess.CalledProcessError as e:
                raise RuntimeError(
                    f"Failed to start container for app '{app}': {e.stderr.strip()}"
                ) from e

        compose_file = self._resolve_compose_file(app)
        cid = self._resolve_container_id(compose_file)
        container = Container(id=cid, port=app_conf.port, app=app_conf.name)
        self.containers.append(container)
        return container.app, container.port


    def stop_container(self, app: str) -> bool:
        target = next((c for c in self.containers if c.app == app), None)
        if target is None:
            return False

        compose_file = self._resolve_compose_file(app)
        try:
            self._run_cmd(self._compose_cmd(compose_file, "down"))
        except subprocess.CalledProcessError as e:
            raise RuntimeError(
                f"Failed to stop container for app '{app}': {e.stderr.strip()}"
            ) from e

        self.containers = [c for c in self.containers if c.app != app]
        return True
    
