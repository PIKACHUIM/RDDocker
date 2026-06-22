# 环境要求

## 系统要求

- **操作系统**：Linux（宿主机）
  - Ubuntu 20.04+ / Debian 11+ / Fedora 37+ / 其他主流发行版均可
  - 不支持 Windows 或 macOS 直接作为容器宿主（WSL2 可尝试但不官方支持）
- **容器引擎**（二选一或多选）：
  - Docker ≥ 24.0
  - Podman ≥ 4.0
  - LXC / LXD（支持 easydesk 统一管理）

## 硬件要求

| 配置项 | 最低 | 推荐 |
|--------|------|------|
| CPU | 2 核 | 4 核+ |
| 内存 | 2 GB（Server 模式）/ 4 GB（桌面模式） | 8 GB+ |
| 磁盘 | 10 GB（Server）/ 20 GB（带桌面） | 50 GB+ |
| 架构 | x86_64 或 ARM64 | x86_64 |

## 网络要求

- 能访问 Docker Hub（`docker.io`）以拉取预构建镜像
- 可选：配置镜像加速以提升拉取速度

```bash
# /etc/docker/daemon.json 示例（添加国内镜像加速）
{
  "registry-mirrors": [
    "https://mirror.gcr.io"
  ]
}
```

- 远程访问所需端口（确保防火墙放行）：

| 服务 | 端口 |
|------|------|
| SSH | 22（容器内） |
| NoMachine NX | 4000 |
| VNC (x11vnc) | 5900 |
| XRDP | 3389 |

## 可选依赖

- **iptables**：用于容器端口转发（easydesk 端口映射功能依赖）
- **NVIDIA 驱动 + nvidia-container-toolkit**：若需在容器内使用 GPU 加速
- **Git**：从源码构建镜像时需要
- **Node.js ≥ 18**：构建本文档站时需要
