# 项目介绍

## 什么是 RDDocker / EasyDesk？

**RDDocker** 是一套完整的桌面容器解决方案，由两部分组成：

- **Docker 镜像构建系统**：为多种 Linux 发行版构建预装桌面环境和远程访问工具的容器镜像
- **easydesk 管理工具**：统一管理 Docker/Podman/LXC/LXD 容器的 CLI 工具和 REST API 服务

借助 EasyDesk，你可以在任意 Linux 宿主机上快速启动一个完整的图形桌面环境，通过 NoMachine、VNC 或 XRDP 远程连接使用。

## 核心功能

- 一键拉取并启动预构建的带桌面容器镜像
- 通过 `easydesk` CLI 或 REST API 管理容器生命周期（创建、启动、停止、删除、执行命令）
- 内置多种远程桌面协议，无需手动配置
- 支持自定义端口映射和软件安装
- 多架构镜像支持（amd64 / arm64）

## 支持矩阵

| 发行版 | 版本 | Server | X11GUI | GNOME3 | Xfce4L | Plasma | GXDeOS | Nirios | 架构 |
|--------|------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|------|
| Debian | 12 (bookworm) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | amd64 / arm64 |
| Debian | 13 (trixie) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | amd64 / arm64 |
| Ubuntu | 24.04 | ✅ | ✅ | ✅ | ✅ | ✅ | - | ✅ | amd64 / arm64 |
| Ubuntu | 26.04 | ✅ | ✅ | ✅ | ✅ | ✅ | - | ✅ | amd64 / arm64 |
| Alpine | 3.19 | ✅ | ✅ | - | ✅ | - | - | - | amd64 / arm64 |
| Alpine | 3.20 | ✅ | ✅ | - | ✅ | - | - | - | amd64 / arm64 |
| Fedora | 40 | ✅ | ✅ | ✅ | ✅ | ✅ | - | ✅ | amd64 / arm64 |
| Fedora | 41 | ✅ | ✅ | ✅ | ✅ | ✅ | - | ✅ | amd64 / arm64 |

### 桌面环境说明

| 标识 | 名称 | 说明 |
|------|------|------|
| Server | 服务器模式 | 无 GUI，仅 SSH，资源占用最低 |
| X11GUI | X11 基础层 | 仅 X11 环境，用于构建其他桌面的基础层，可配合 NoMachine/VNC/XRDP 使用 |
| GNOME3 | GNOME 桌面 | 完整 GNOME 3 桌面环境 |
| Xfce4L | Xfce4 轻量桌面 | 轻量级 Xfce4，适合低配环境 |
| Plasma | KDE Plasma | KDE Plasma 桌面，功能丰富 |
| GXDeOS | GXDE 桌面 | 基于 Deepin 的 GXDE 桌面（仅 Debian） |
| Nirios | Niri Wayland | Niri Wayland 平铺窗口管理器 |

## 镜像分层架构

镜像采用分层构建，层层继承：

```
Base OS (Debian/Ubuntu/Alpine/Fedora)
    └── Server（基础工具 + SSH）
            └── X11GUI（X11 + NoMachine/VNC/XRDP）
                    ├── GNOME3
                    ├── Xfce4L
                    ├── Plasma
                    ├── GXDeOS
                    └── Nirios
```

这种分层方式使镜像复用基础层，减少重复内容，也便于单独维护每一层。

## 与传统虚拟机的对比

| 特性 | EasyDesk 容器 | 传统虚拟机 |
|------|:------------:|:----------:|
| 启动速度 | 秒级 | 分钟级 |
| 资源占用 | 低（共享内核） | 高（独立内核） |
| 镜像大小 | 较小 | 较大 |
| 隔离程度 | 进程级 | 硬件级 |
| 快照/迁移 | 简单（docker commit/export） | 依赖虚拟化平台 |
| 远程桌面 | 内置，开箱即用 | 需手动配置 |
| 多架构 | 原生支持 | 依赖虚拟化支持 |
