# Docker 部署指南

## 前置要求

1. 安装 Docker
2. 安装 Docker Compose (Docker 20.10+ 已内置)

## 配置说明

环境变量配置在 `.env` 文件中：

```bash
# 数据库配置
DB_ROOT_PASSWORD=Cz1174520425!!
DB_NAME=grid
DB_PORT=3306

# Redis 配置
REDIS_PWD=Cz1174520425!!
REDIS_PORT=6379

# 后端端口
BACKEND_PORT=8000

# 前端端口
FRONTEND_PORT=8001
```

## 部署步骤

### 1. 构建并启动所有服务

```bash
cd /home/nano/littlegrid
docker compose up -d
```

### 2. 查看服务状态

```bash
docker compose ps
```

### 3. 查看日志

```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f backend
docker compose logs -f mysql
```

### 4. 停止服务

```bash
docker compose stop
```

### 5. 启动服务

```bash
docker compose start
```

### 6. 重启服务

```bash
docker compose restart
```

### 7. 停止并删除容器

```bash
docker compose down

# 同时删除数据卷（谨慎使用）
docker compose down -v
```

## 访问地址

- 前端: http://你的服务器IP
- 后端: http://你的服务器IP:8000
- 数据库: localhost:3306
- Redis: localhost:6379

## 数据持久化

- MySQL 数据存储在 Docker 卷 `mysql-data` 中
- Redis 数据存储在 Docker 卷 `redis-data` 中
- 后端日志映射到 `./backend/logs` 目录

## 常见问题

### 1. 端口冲突

如果端口被占用，修改 `.env` 文件中的端口配置。

### 2. 重新构建镜像

```bash
# 重新构建并启动
docker compose up -d --build

# 仅重新构建某个服务
docker compose build backend
docker compose build frontend
```

### 3. 清理未使用的镜像和卷

```bash
docker system prune -a --volumes
```

### 4. 进入容器调试

```bash
# 进入后端容器
docker exec -it littlegrid-backend sh

# 进入 MySQL 容器
docker exec -it littlegrid-mysql mysql -uroot -p

# 进入 Redis 容器
docker exec -it littlegrid-redis redis-cli -a $REDIS_PWD
```

## 架构说明

```
┌─────────────────────────────────────────┐
│           Nginx (Frontend)              │
│              Port: 80                   │
└──────────────────┬──────────────────────┘
                   │ /api
                   ▼
┌─────────────────────────────────────────┐
│     Spring Boot (Backend)               │
│            Port: 8000                   │
└────────┬────────────────┬───────────────┘
         │                │
         ▼                ▼
┌─────────────┐   ┌─────────────┐
│  MySQL 8.0  │   │  Redis 7    │
│  Port: 3306 │   │  Port: 6379 │
└─────────────┘   └─────────────┘
```
