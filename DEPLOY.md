# LittleGrid Docker 部署指南

## 快速开始

### 1. 首次部署

```bash
cd /home/nano/littlegrid
./deploy.sh start
```

### 2. 更新代码

```bash
./deploy.sh update
```

## 脚本命令

| 命令 | 说明 |
|------|------|
| `./deploy.sh start` | 首次部署并启动所有服务 |
| `./deploy.sh build` | 重新构建并启动服务 |
| `./deploy.sh update` | 拉取最新代码并重新构建 |
| `./` | 重启所有服务 |
| `./deploy.sh stop` | 停止所有服务 |
| `./deploy.sh logs` | 查看所有服务日志 |
| `./deploy.sh status` | 查看服务状态 |
| `./deploy.sh clean` | 清理未使用的镜像和卷 |
| `./deploy.sh help` | 显示帮助信息 |

## 访问地址

| 服务 | 地址 |
|------|------|
| 前端 | http://服务器IP:8001 |
| 后端 | http://服务器IP:8000 |
| MySQL | localhost:3306 |
| Redis | localhost:6379 |

## 手动 Docker 命令

如果需要手动操作：

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重新构建
docker compose up -d --build

# 查看日志
docker compose logs -f

# 查看状态
docker compose ps
```

## 端口配置

当前端口映射：

- **前端**: 8001 (容器内) → 8001 (服务器)
- **后端**: 8000 (容器内) → 8000 (服务器)
- **MySQL**: 3306 (容器内) → 3306 (服务器)
- **Redis**: 6379 (容器内) → 6379 (服务器)

修改端口请编辑 `.env` 文件。

## 数据持久化

- MySQL 数据: `mysql-data` 卷
- Redis 数据: `redis-data` 卷
- 后端日志: `./backend/logs` 目录

## 故障排查

### 查看特定服务日志

```bash
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mysql
docker compose logs -f redis
```

### 进入容器

```bash
# 后端
docker exec -it littlegrid-backend sh

# MySQL
docker exec -it littlegrid-mysql mysql -uroot -p

# Redis
docker exec -it littlegrid-redis redis-cli -a $REDIS_PWD
```

### 端口冲突

如果端口被占用，修改 `.env` 文件：

```bash
# 修改后端端口
BACKEND_PORT=8000

# 修改前端端口
FRONTEND_PORT=8001
```

然后执行 `./deploy.sh restart`
