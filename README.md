# llmfuzz-rewrite

## Run Pipelines

The application now uses a **single configuration entry file**: `apps.json`.

Before running, edit `apps.json` as needed:

- `runtime.selected_app`: target app (`i_educar`, `crm`, or `torrentpier`)
- `runtime.use_container`: whether to auto-start containers
- `runtime.verifier_port`: callback listener port for verifier
- `runtime.verifier_host`: verifier callback host passed to containers
- `opencode_agent.*`: model and timeout behavior for the attack agent

Minimal example:

```json
{
	"runtime": {
		"selected_app": "crm",
		"use_container": true,
		"verifier_port": 8000,
		"verifier_host": "host.docker.internal"
	},
	"opencode_agent": {
		"model": "paratera/DeepSeek-R1-0528",
		"timeout_seconds": 1800,
		"idle_timeout_seconds": 300,
		"startup_timeout_seconds": 300
	},
	"apps": [
		{ "name": "i_educar", "port": 8080, "start_script": "examples/i_educar/start.sh" },
		{ "name": "crm", "port": 8080, "start_script": "examples/crm/start.sh" },
		{ "name": "torrentpier", "port": 3200, "start_script": "examples/torrentpier/start.sh" }
	]
}
```

### TorrentPier (ACR 镜像流程)

`examples/torrentpier/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${TORRENTPIER_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/torrentpier/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（构建并推送应用镜像 + MariaDB revping 定制镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

说明：`start.sh` 会自动在数据库中确保 `rev_ping()` 函数存在，用于漏洞验证回调。

Run:

```bash
python main.py
```
