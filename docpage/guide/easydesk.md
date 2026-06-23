# deskcli CLI

`deskcli` 是 RDDocker 的统一容器管理工具，支持 Docker、Podman、LXC、LXD 四种后端。

## 配置管理

```bash
# 设置配置项
deskcli configs set engine <docker|podman|lxc|lxd>
deskcli configs set token <your_token>
deskcli configs set port <api_port>

# 读取配置项
deskcli configs get engine
deskcli configs get token
deskcli configs get port
```

## 容器管理

### 列出所有容器

```bash
deskcli list
```

### 启动 / 停止 / 重启 / 删除容器

```bash
deskcli start my-container
deskcli stop my-container
deskcli restart my-container
deskcli rm my-container
```

### 在容器内执行命令

```bash
# 前台执行（等待命令完成）
deskcli exec my-container ls -la /home

# 后台执行（detach 模式）
deskcli -d exec my-container bash -c "nohup ./start.sh &"
```

## 桌面容器管理（desk 子命令）

`desk` 子命令专为带桌面环境的容器设计，提供更高层的封装。

### 列出桌面容器

```bash
deskcli desk list
```

### 创建新的桌面容器

```bash
deskcli desk new <image> [flags]
```

常用 flags：

| Flag | 说明 | 示例 |
|------|------|------|
| `--name <n>` | 容器名称 | `--name my-desktop` |
| `--port <ext:int>` | 端口映射（可多次使用） | `--port 4000:4000` |
| `--add-soft <s>` | 安装额外软件（可多次使用） | `--add-soft firefox` |

完整示例：

```bash
deskcli desk new pikachuim/debian:12-xfce4l \
  --name dev-box \
  --port 2222:22 \
  --port 4000:4000 \
  --port 5900:5900 \
  --add-soft firefox \
  --add-soft vscode
```

### 运行桌面容器（临时）

```bash
deskcli desk run pikachuim/debian:12-xfce4l --port 4000:4000
```

### 桌面容器生命周期

```bash
deskcli desk start my-desktop
deskcli desk stop my-desktop
deskcli desk restart my-desktop
deskcli desk rm my-desktop
```

### 在桌面容器内执行命令

```bash
deskcli desk exec my-desktop xrandr --listmonitors
```

## 启动 API 服务

`deskcli serve` 启动 REST API 服务端，供其他工具或脚本通过 HTTP 调用：

```bash
# 使用默认配置的端口启动
deskcli serve

# 指定端口（覆盖配置）
deskcli configs set port 9090
deskcli serve
```

API 服务启动后，可通过 `http://localhost:<port>/api/v1` 访问，详细接口见 [API 参考](/api/reference)。

## 常见使用场景

### 快速起一个开发环境

```bash
deskcli desk new pikachuim/debian:12-xfce4l \
  --name dev \
  --port 2222:22 \
  --port 4000:4000 \
  --add-soft vscode
# 用 NoMachine 连接 host:4000 或 SSH: ssh -p 2222 user@host
```

### 批量管理多个容器

```bash
# 列出所有容器
deskcli list

# 停止所有桌面容器（结合 shell）
for name in $(deskcli desk list | awk '{print $1}'); do
  deskcli desk stop "$name"
done
```

### 修改容器内用户密码

```bash
deskcli exec my-desktop passwd user
# 或通过 API
curl -X POST http://localhost:8080/api/v1/containers/my-desktop/passwd \
  -H "X-Token: your_token" \
  -d '{"password": "newpass"}'
```
