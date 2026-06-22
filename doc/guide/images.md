# 镜像使用

## 镜像命名规则

所有预构建镜像发布在 Docker Hub，命名格式为：

```
pikachuim/{os}:{version}-{desktop}
```

示例：
- `pikachuim/debian:12-xfce4l` — Debian 12 + Xfce4 轻量桌面
- `pikachuim/ubuntu:24.04-gnome3` — Ubuntu 24.04 + GNOME 桌面
- `pikachuim/debian:13-plasma` — Debian 13 + KDE Plasma
- `pikachuim/alpine:3.20-server` — Alpine 3.20 服务器模式（无 GUI）

桌面标识对应关系：

| 标识 | 桌面 |
|------|------|
| `server` | 无 GUI，仅 SSH |
| `x11gui` | X11 基础层 |
| `gnome3` | GNOME 3 |
| `xfce4l` | Xfce4 |
| `plasma` | KDE Plasma |
| `gxdeos` | GXDE |
| `nirios` | Niri Wayland |

## 各镜像说明与推荐用途

| 镜像 | 推荐用途 | 内存需求 |
|------|----------|----------|
| `*-server` | 纯命令行开发、CI 环境、轻量服务 | ~256 MB |
| `*-x11gui` | 需要 GUI 但不限定桌面、NoMachine 自定义 | ~512 MB |
| `*-xfce4l` | 日常使用、低配机器、远程轻量桌面 | ~1 GB |
| `*-gnome3` | 功能完整的 GNOME 工作环境 | ~2 GB |
| `*-plasma` | KDE 生态、定制化桌面 | ~2 GB |
| `*-gxdeos` | GXDE/Deepin 风格桌面（仅 Debian） | ~2 GB |
| `*-nirios` | Wayland 平铺窗口管理，键盘驱动工作流 | ~1 GB |

## docker run 示例

### 服务器模式（仅 SSH）

```bash
docker run -d \
  --name srv \
  -p 2222:22 \
  pikachuim/debian:12-server
```

### Xfce4 轻量桌面（推荐入门）

```bash
docker run -d \
  --name xfce-desk \
  -p 2222:22 \
  -p 4000:4000 \
  -p 5900:5900 \
  -p 3389:3389 \
  pikachuim/debian:12-xfce4l
```

### GNOME 桌面

```bash
docker run -d \
  --name gnome-desk \
  -p 2222:22 \
  -p 4000:4000 \
  -p 5900:5900 \
  -p 3389:3389 \
  --shm-size=2g \
  pikachuim/ubuntu:24.04-gnome3
```

### 挂载本地目录

```bash
docker run -d \
  --name my-desk \
  -p 4000:4000 \
  -v /home/user/workspace:/home/user/workspace \
  pikachuim/debian:12-xfce4l
```

## 使用 easydesk 启动镜像

```bash
# 创建并启动桌面容器
easydesk desk new pikachuim/debian:12-xfce4l \
  --name my-desktop \
  --port 4000:4000 \
  --port 5900:5900 \
  --port 2222:22

# 安装额外软件
easydesk desk new pikachuim/debian:12-xfce4l \
  --name dev-desktop \
  --add-soft firefox \
  --add-soft vscode \
  --port 4000:4000
```

## 自定义构建（build-arg）

从源码构建时，可通过 `--build-arg` 在镜像内预装软件：

```bash
docker build \
  --build-arg INSTALL_FIREFOX=true \
  --build-arg INSTALL_VSCODE=true \
  --build-arg INSTALL_CHROMIUM=true \
  -f Dockers/Debian/Desktops/GNOME3 \
  -t my-desktop .
```

常用 build-arg 列表（以 Debian GNOME3 为例）：

| 参数 | 说明 |
|------|------|
| `INSTALL_FIREFOX=true` | 安装 Firefox 浏览器 |
| `INSTALL_CHROMIUM=true` | 安装 Chromium 浏览器 |
| `INSTALL_VSCODE=true` | 安装 VS Code |
| `INSTALL_LIBREOFFICE=true` | 安装 LibreOffice |

## 远程连接

| 协议 | 端口 | 推荐客户端 |
|------|------|-----------|
| NoMachine NX | 4000 | [NoMachine 客户端](https://www.nomachine.com/download) |
| VNC | 5900 | TigerVNC、RealVNC、Remmina |
| XRDP | 3389 | Windows 远程桌面、Remmina |
| SSH | 22（映射到宿主任意端口） | OpenSSH、PuTTY |
