import shutil
import tempfile
from pathlib import Path

from app_config import load_project_config
from agents.opencode import OpenCodeAgent
from container import ContainerManager
from verifier import Verifier
from verifiers.admidio_verifier import AdmidioVerifier
from verifiers.crm_verifier import CRMVerifier
from verifiers.i_educar_verifier import IEduVerifier
from verifiers.torrentpier_verifier import TorrentPierVerifier


def _render_prompt(template_path: Path, target_port: int) -> str:
    template = template_path.read_text(encoding="utf-8")
    return template.replace("{{TARGET_PORT}}", str(target_port))


def _copy_into_sandbox(project_root: Path, sandbox_root: Path, rel_path: Path):
    src = project_root / rel_path
    if not src.exists():
        raise FileNotFoundError(f"Required sandbox path not found: {src}")

    dst = sandbox_root / rel_path
    if src.is_dir():
        shutil.copytree(src, dst, dirs_exist_ok=True)
    else:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)


def _prepare_agent_sandbox(
    app_name: str,
    prompt_path: Path,
    sandbox_assets: list[Path],
) -> tuple[Path, Path]:
    project_root = Path(__file__).resolve().parent
    sandbox_root = Path(tempfile.mkdtemp(prefix=f"llmfuzz-{app_name}-"))

    _copy_into_sandbox(project_root, sandbox_root, prompt_path)
    for rel_path in sandbox_assets:
        _copy_into_sandbox(project_root, sandbox_root, rel_path)

    return sandbox_root, sandbox_root / prompt_path


def _resolve_components(app_name: str) -> tuple[Path, type[Verifier], list[Path]]:
    mapping: dict[str, tuple[Path, type[Verifier], list[Path]]] = {
        "i_educar": (
            Path("prompts/i_educar.md"),
            IEduVerifier,
            [
                Path("sources/i_educar"),
                Path("examples/i_educar/static_report.json"),
                Path("examples/i_educar/compose.yaml"),
                Path("examples/i_educar/start.sh"),
                Path("examples/i_educar/postgres-rev-ping"),
            ],
        ),
        "crm": (
            Path("prompts/crm.md"),
            CRMVerifier,
            [
                Path("sources/CRM"),
                Path("examples/crm/static_report.json"),
                Path("examples/crm/compose.yaml"),
                Path("examples/crm/start.sh"),
            ],
        ),
        "admidio": (
            Path("prompts/admidio.md"),
            AdmidioVerifier,
            [
                Path("sources/admidio"),
                Path("examples/admidio"),
            ],
        ),
        "torrentpier": (
            Path("prompts/torrentpier.md"),
            TorrentPierVerifier,
            [
                Path("sources/torrentpier"),
                Path("examples/torrentpier"),
            ],
        ),
    }

    if app_name not in mapping:
        supported = ", ".join(sorted(mapping))
        raise ValueError(f"Unsupported app '{app_name}'. Supported apps: {supported}")

    return mapping[app_name]


def main():
    project_config = load_project_config("apps.json")
    container_manager = ContainerManager.build("apps.json")
    selected_app = project_config.runtime.selected_app
    verifier_port = project_config.runtime.verifier_port
    verifier_host = project_config.runtime.verifier_host
    app_name: str | None = None
    container_started = False
    use_container = project_config.runtime.use_container
    sandbox_root: Path | None = None

    app_conf = next((a for a in container_manager.apps if a.name == selected_app), None)
    if app_conf is None:
        raise ValueError(f"app '{selected_app}' is missing in apps.json")

    prompt_path, verifier_cls, sandbox_assets = _resolve_components(selected_app)

    port = app_conf.port
    agent: OpenCodeAgent | None = None

    try:
        sandbox_root, sandbox_prompt_path = _prepare_agent_sandbox(
            selected_app,
            prompt_path,
            sandbox_assets,
        )
        print(f"agent sandbox prepared: {sandbox_root}")

        agent_kwargs = project_config.opencode_agent.model_dump(exclude_none=True)
        sandbox_root_abs = str(sandbox_root.resolve())
        agent_kwargs["working_dir"] = sandbox_root_abs
        agent_kwargs["allowed_roots"] = [sandbox_root_abs]
        agent_kwargs["writable_roots"] = [sandbox_root_abs, "/tmp"]
        agent = OpenCodeAgent(**agent_kwargs)

        if use_container:
            try:
                app_name, port = container_manager.new_container(
                    selected_app,
                    verifier_port=verifier_port,
                    verifier_host=verifier_host,
                )
                container_started = True
                print(f"container started: app={app_name}, port={port}")
            except Exception as e:
                print(f"container startup skipped: {e}")
                print(f"fallback to configured target port: {port}")
        else:
            print("container startup skipped: set runtime.use_container=true in apps.json to enable")
            print(f"using configured target port: {port}")

        prompt = _render_prompt(sandbox_prompt_path, target_port=port)

        verifier: Verifier = verifier_cls.build(on_call_port=verifier_port)
        print(
            f"starting attack for app={selected_app} on port={port} (this may take a few minutes before first output)",
            flush=True,
        )

        try:
            verified = verifier.verify(agent, prompt)
        except Exception as e:
            print(f"verify failed: {e}")
            verified = False

        print("===== opencode output begin =====")
        print(agent.last_output.strip() or "<empty>")
        print("===== opencode output end =====")
        print(f"verify result: {verified}")
    finally:
        if sandbox_root is not None:
            shutil.rmtree(sandbox_root, ignore_errors=True)
            print(f"agent sandbox cleaned: {sandbox_root}")

        if container_started and app_name is not None:
            stopped = container_manager.stop_container(app_name)
            print(f"container stopped: {stopped}")


if __name__ == "__main__":
    main()
