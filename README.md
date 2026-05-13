# llmfuzz-rewrite

## Run Pipelines

The application now uses a **single configuration entry file**: `apps.json`.

### 新增项目镜像流程规范（ACR）

当新增一个项目（新 `examples/<app>/`）时，镜像流程统一如下：

1. **先本地构建**（应用镜像 + 数据库定制镜像）
2. 本地构建成功后，再 **push 到阿里云 ACR**
3. 运行阶段默认优先拉取 ACR 镜像；若镜像暂未推送，`start.sh` 应支持本地构建兜底

推荐约定：每个新项目提供 `build_and_push.sh`，并保持“build 在前、push 在后”的顺序。

Before running, edit `apps.json` as needed:

- `runtime.selected_app`: target app (`i_educar`, `crm`, `admidio`, `torrentpier`, `phpmyfaq`, `mylittleforum`, `cloudlog`, or `atomboard`)
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

### Admidio (ACR 镜像流程)

`examples/admidio/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${ADMIDIO_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/admidio/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（**先本地构建，再推送**应用镜像 + MariaDB revping 镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

### phpMyFAQ (ACR 镜像流程)

`examples/phpmyfaq/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${PHPMYFAQ_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/phpmyfaq/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（**先本地构建，再推送**应用镜像 + MariaDB revping 镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

说明：`start.sh` 会自动执行 phpMyFAQ setup 初始化，并在数据库中确保 `rev_ping()` 函数存在，用于漏洞验证回调。

### mylittleforum (ACR 镜像流程)

`examples/mylittleforum/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${MYLITTLEFORUM_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/mylittleforum/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（**先本地构建，再推送**应用镜像 + MariaDB revping 镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

说明：`start.sh` 会自动导入基础数据、设置默认管理员账号，并在数据库中确保 `rev_ping()` 函数存在，用于漏洞验证回调。

### Cloudlog (ACR 镜像流程)

`examples/cloudlog/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${CLOUDLOG_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/cloudlog/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（**先本地构建，再推送**应用镜像 + MariaDB revping 镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

说明：`start.sh` 会自动确保 Cloudlog 登录可用、初始化默认管理员账号，并在数据库中确保 `rev_ping()` 函数存在，用于漏洞验证回调。

### AtomBoard (ACR 镜像流程)

`examples/atomboard/compose.yaml` 默认使用阿里云 ACR 镜像前缀（可在 `.env` 覆盖）：

- 应用镜像：`${REGISTRY_IMAGE_PREFIX}:${ATOMBOARD_IMAGE_TAG}`
- 数据库镜像：`${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}`

首次使用建议：

1. 在 `examples/atomboard/` 下复制环境文件：`.env.example -> .env`
2. 执行 `build_and_push.sh`（**先本地构建，再推送**应用镜像 + MariaDB revping 镜像到 ACR）
3. 通过 `start.sh` 启动服务（或由 `python main.py` 自动调用）

说明：`start.sh` 会自动生成/同步 `settings.php`（启用 `mysqli`）、验证管理员登录能力，并在数据库中确保 `rev_ping()` 函数存在，用于漏洞验证回调。

Run:

```bash
python main.py
```
