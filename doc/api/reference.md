# API 参考

`easydesk serve` 启动后提供 REST API，供脚本或外部系统调用。

- **Base URL**：`http://<host>:<port>/api/v1`
- **认证**：所有接口需在请求头携带 `X-Token: <token>`

---

## 容器列表

**GET** `/containers`

列出所有受管容器。

```bash
curl -H "X-Token: your_token" http://localhost:8080/api/v1/containers
```

响应示例：

```json
[
  {
    "name": "my-desktop",
    "image": "pikachuim/debian:12-xfce4l",
    "status": "running",
    "ports": ["4000:4000", "5900:5900", "2222:22"]
  }
]
```

---

## 创建容器

**POST** `/containers`

```bash
curl -X POST http://localhost:8080/api/v1/containers \
  -H "X-Token: your_token" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-desktop",
    "image": "pikachuim/debian:12-xfce4l",
    "ports": ["4000:4000", "5900:5900", "2222:22"]
  }'
```

请求体字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 容器名称（必填） |
| `image` | string | 镜像名称（必填） |
| `ports` | string[] | 端口映射列表，格式 `"宿主:容器"` |
| `volumes` | string[] | 挂载卷列表 |
| `env` | object | 环境变量 |

---

## 获取容器详情

**GET** `/containers/:name`

```bash
curl -H "X-Token: your_token" http://localhost:8080/api/v1/containers/my-desktop
```

响应示例：

```json
{
  "name": "my-desktop",
  "image": "pikachuim/debian:12-xfce4l",
  "status": "running",
  "created": "2024-01-01T00:00:00Z",
  "ports": ["4000:4000", "5900:5900", "2222:22"]
}
```

---

## 删除容器

**DELETE** `/containers/:name`

```bash
curl -X DELETE -H "X-Token: your_token" \
  http://localhost:8080/api/v1/containers/my-desktop
```

---

## 启动容器

**POST** `/containers/:name/start`

```bash
curl -X POST -H "X-Token: your_token" \
  http://localhost:8080/api/v1/containers/my-desktop/start
```

---

## 停止容器

**POST** `/containers/:name/stop`

```bash
curl -X POST -H "X-Token: your_token" \
  http://localhost:8080/api/v1/containers/my-desktop/stop
```

---

## 重启容器

**POST** `/containers/:name/restart`

```bash
curl -X POST -H "X-Token: your_token" \
  http://localhost:8080/api/v1/containers/my-desktop/restart
```

---

## 执行命令

**POST** `/containers/:name/exec`

```bash
curl -X POST http://localhost:8080/api/v1/containers/my-desktop/exec \
  -H "X-Token: your_token" \
  -H "Content-Type: application/json" \
  -d '{"cmd": "ls -la /home/user"}'
```

请求体：

| 字段 | 类型 | 说明 |
|------|------|------|
| `cmd` | string | 要执行的命令 |
| `detach` | bool | 是否后台执行（默认 false） |

响应示例：

```json
{
  "output": "total 32\ndrwxr-xr-x ...",
  "exit_code": 0
}
```

---

## 修改密码

**POST** `/containers/:name/passwd`

```bash
curl -X POST http://localhost:8080/api/v1/containers/my-desktop/passwd \
  -H "X-Token: your_token" \
  -H "Content-Type: application/json" \
  -d '{"password": "newpassword"}'
```

---

## 错误码

| HTTP 状态码 | 说明 |
|------------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 认证失败（Token 无效） |
| 404 | 容器不存在 |
| 500 | 服务器内部错误 |

错误响应格式：

```json
{
  "error": "container not found: my-desktop"
}
```
