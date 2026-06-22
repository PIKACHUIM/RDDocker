# EasyDesk CLI

`easydesk` 是 RDDockerRepo 的统一容器管理工具，支持 Docker、Podman、LXC、LXD 四种后端。

## 配置管理

```bash
# 设置配置项
easydesk conf set engine <docker|podman|lxc|lxd>
easydesk conf set token <your_token>
easydesk conf set port <api_port>

# 读取配置项
easydesk conf get engine
easydesk conf get token
easydesk conf get port
```

## 容器管理

### 列出所有容器

```bash
easydesk list
```

### 启动 / 停止 / 重启 / 删除容器

```bash
easydesk start my-container
easydesk stop my-container
easydesk restart my-container
easydesk rm my-container
```

### 在容器内执行命令

```bash
# 前台执行（等待命令完成）
easydesk exec my-container ls -la /home

# 后台执行（detach 模式）
easydesk -d exec my-container bash -c "nohup ./start.sh &"
```

## 桌面容器管理（desk 子命令）

`desk` 子命令专为带桌面环境的容器设计，提供更高层的封装。

### 列出桌面容器

```bash
easydesk desk list
```

### 创建新的桌面容器

```bash
easydesk desk new <image> [flags]
```

常用 flags：

| Flag | 说明 | 示例 |
|------|------|------|
| `--name <n>` | 容器名称 | `--name my-desktop` |
| `--port <ext:int>` | 端口映射（可多次使用） | `--port 4000:4000` |
| `--add-soft <s>` | 安装额外软件（可多次使用） | `--add-soft firefox` |

完整示例：

```bash
easydesk desk new pikachuim/debian:12-xfce4l \
  --name dev-box \
  --port 2222:22 \
  --port 4000:4000 \
  --port 5900:5900 \
  --add-soft firefox \
  --add-soft vscode
```

### 运行桌面容器（临时）

```bash
easydesk desk run pikachuim/debian:12-xfce4l --port 4000:4000
```

### 桌面容器生命周期

```bash
easydesk desk start my-desktop
easydesk desk stop my-desktop
easydesk desk restart my-desktop
easydesk desk rm my-desktop
```

### 在桌面容器内执行命令

```bash
easydesk desk exec my-desktop xrandr --listmonitors
```

## 启动 API 服务

`easydesk serve` 启动 REST API 服务端，供其他工具或脚本通过 HTTP 调用：

```bash
# 使用默认配置的端口启动
easydesk serve

# 指定端口（覆盖配置）
easydesk conf set port 9090
easydesk serve
```

API 服务启动后，可通过 `http://localhost:<port>/api/v1` 访问，详细接口见 [API 参考](/api/reference)。

## 常见使用场景

### 快速起一个开发环境

```bash
easydesk desk new pikachuim/debian:12-xfce4l \
  --name dev \
  --port 2222:22 \
  --port 4000:4000 \
  --add-soft vscode
# 用 NoMachine 连接 host:4000 或 SSH: ssh -p 2222 user@host
```

### 批量管理多个容器

```bash
# 列出所有容器
easydesk list

# 停止所有桌面容器（结合 shell）
for name in $(easydesk desk list | awk '{print $1}'); do
  easydesk desk stop "$name"
done
```

### 修改容器内用户密码

```bash
easydesk exec my-desktop passwd user
# 或通过 API
curl -X POST http://localhost:8080/api/v1/containers/my-desktop/passwd \
  -H "X-Token: your_token" \
  -d '{"password": "newpass"}'
```
