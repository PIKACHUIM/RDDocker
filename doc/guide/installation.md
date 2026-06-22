# 安装方法

## 方式一：直接使用预构建镜像（推荐）

无需安装任何额外工具，直接使用 `docker run` 拉取并启动镜像。

```bash
# 示例：启动 Debian 12 + Xfce4 桌面
docker run -d \
  --name my-desktop \
  -p 4000:4000 \
  -p 5900:5900 \
  -p 3389:3389 \
  -p 2222:22 \
  pikachuim/debian:12-xfce4l
```

启动后通过 NoMachine（端口 4000）、VNC（端口 5900）或 XRDP（端口 3389）连接。

默认凭据请参考镜像说明，建议首次启动后立即修改密码：

```bash
docker exec my-desktop passwd user
```

## 方式二：安装 easydesk 管理工具

`easydesk` 提供统一的 CLI 和 REST API 来管理多种容器后端。

### 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/PIKACHUIM/RDDocker/master/easydesk/install.sh | bash
```

### 验证安装

```bash
easydesk --version
```

### 初始配置

```bash
# 设置容器引擎（docker / podman / lxc / lxd）
easydesk conf set engine docker

# 设置 API 访问令牌（用于 REST API 认证）
easydesk conf set token your_secret_token

# 设置 API 服务端口（默认 8080）
easydesk conf set port 8080
```

### 创建第一个桌面容器

```bash
easydesk desk new pikachuim/debian:12-xfce4l \
  --name my-desktop \
  --port 4000:4000 \
  --port 5900:5900 \
  --port 2222:22
```

## 方式三：从源码构建镜像

适合需要自定义镜像内容的用户。

### 克隆仓库

```bash
git clone https://github.com/PIKACHUIM/RDDocker.git
cd RDDocker
```

### 运行构建脚本

```bash
# 构建所有镜像
bash Builder.sh

# 或单独构建某个镜像（示例：Debian 12 GNOME）
docker build \
  -f Dockers/Debian/Desktops/GNOME3 \
  -t my-debian-gnome .
```

### 使用 build-arg 自定义软件

```bash
docker build \
  --build-arg INSTALL_FIREFOX=true \
  --build-arg INSTALL_VSCODE=true \
  -f Dockers/Debian/Desktops/GNOME3 \
  -t my-debian-gnome-custom .
```

## 构建本文档

```bash
cd doc
npm install
npm run docs:dev     # 本地预览（http://localhost:5173）
npm run docs:build   # 构建静态文件到 .vitepress/dist/
```
