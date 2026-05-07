# Docker 镜像构建与推送指南（国内 Registry）

本文档描述如何将 i-educar 的两个镜像构建并推送到国内容器镜像服务（以阿里云 ACR 为例），
再通过 `REGISTRY` 环境变量令两个 Compose 文件直接拉取国内镜像，避免因网络问题导致构建失败。

---

## 一、前提条件

| 工具 | 最低版本 |
|------|----------|
| Docker | 24+ |
| Docker Compose | v2.20+ (`docker compose` 子命令) |

国内 Registry 选型（任选其一）：

| 服务 | Registry 前缀示例 |
|------|-------------------|
| 阿里云 ACR（个人/企业版） | `registry.cn-hangzhou.aliyuncs.com/<命名空间>` |
| 腾讯云 TCR | `ccr.ccs.tencentyun.com/<命名空间>` |
| 华为云 SWR | `swr.cn-east-3.myhuaweicloud.com/<组织>` |

> 下文以 **阿里云 ACR** 为例，请将 `<YOUR_NAMESPACE>` 替换为你自己的命名空间。

---

## 二、登录国内 Registry

```bash
docker login registry.cn-hangzhou.aliyuncs.com
# 按提示输入阿里云账号（邮箱/手机）及访问凭证（RAM 子账号密码或访问令牌）
```

---

## 三、构建镜像

两个镜像对应两个不同的 Dockerfile：

### 3.1 生产镜像（`ieducar`）

用于 `docker-compose.full.yml` 中的 `app` / `horizon` / `init` 服务。

```bash
# 在项目根目录执行（Dockerfile 依赖 . 作为 build context）
cd /path/to/i_educar

docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg COMPOSER_VERSION=2.8 \
  -f docker/deploy/Dockerfile \
  -t registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:2.10.0 \
  -t registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:latest \
  .
```

### 3.2 开发镜像（`ieducar-php`）

用于 `docker-compose.yml` 中的 `php` / `fpm` / `horizon` 服务。

```bash
docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg COMPOSER_VERSION=2.8 \
  -f docker/php/Dockerfile \
  -t registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar-php:8.4 \
  -t registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar-php:latest \
  docker/php
```

---

## 四、推送镜像

```bash
# 生产镜像
docker push registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:2.10.0
docker push registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:latest

# 开发镜像
docker push registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar-php:8.4
docker push registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar-php:latest
```

---

## 五、配置 `.env` 并启动

两个 Compose 文件都通过 `REGISTRY` 环境变量控制镜像前缀，默认值已写在文件中作为占位符。
在 `.env` 中添加以下内容（或直接 `export`）：

```dotenv
# .env（或在 shell 中 export）
REGISTRY=registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>
```

然后正常启动：

```bash
# 生产部署
docker compose -f docker-compose.full.yml pull   # 从国内 Registry 拉取
docker compose -f docker-compose.full.yml up -d

# 开发环境
docker compose pull
docker compose up -d
```

---

## 六、后续版本升级

```bash
# 重新 build 并打新 tag
docker build ... -t registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:2.11.0 .

# 推送
docker push registry.cn-hangzhou.aliyuncs.com/<YOUR_NAMESPACE>/ieducar:2.11.0

# 更新 .env 或 Compose 文件中的版本号
IEDUCAR_IMAGE_TAG=2.11.0 docker compose -f docker-compose.full.yml up -d
```
