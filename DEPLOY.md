# LittleGrid Docker 部署指南

## 目录

- [部署架构](#部署架构)
- [环境配置](#环境配置)
- [方式一：一键部署（推荐）](#方式一一键部署推荐)
- [方式二：独立部署](#方式二独立部署)
- [管理脚本](#管理脚本)
- [更新服务](#更新服务)
- [故障排查](#故障排查)

---

## 部署架构

```
┌─────────────────────────────────────────────────────────────┐
│                        服务器                                 │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   MySQL      │  │    Redis     │  │  Spring Boot │       │
│  │   :3306      │  │    :6379     │  │    :8000     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           │                                  │
│                    ┌──────┴──────┐                           │
│                    │   Frontend  │                           │
│                    │    :8001    │                           │
│                    └─────────────┘                           │
└─────────────────────────────────────────────────────────────┘

访问地址：
- Admin 后台:  http://服务器IP:8001
- Backend API: http://服务器IP:8000
- App API:     http://服务器IP:8000/api/app/*
```

---

## 环境配置

创建 `.env` 文件：

```bash
# ============================================================
# MySQL 配置
# ============================================================
DB_ROOT_PASSWORD=your_mysql_password_here
DB_NAME=eladmin
DB_PORT=3306

# ============================================================
# Redis 配置
# ============================================================
REDIS_PWD=your_redis_password_here
REDIS_PORT=6379

# ============================================================
# 服务端口配置
# ============================================================
BACKEND_PORT=8000
FRONTEND_PORT=8001
```

---

## 方式一：一键部署（推荐）

### 首次部署

```bash
cd /home/nano/littlegrid
./deploy.sh start
```

### 更新部署

```bash
./deploy.sh update
```

### 脚本命令

| 命令 | 说明 |
|------|------|
| `./deploy.sh start` | 首次部署并启动所有服务 |
| `./deploy.sh build` | 重新构建并启动服务 |
| `./deploy.sh update` | 拉取最新代码并重新构建 |
| `./deploy.sh restart` | 重启所有服务 |
| `./deploy.sh stop` | 停止所有服务 |
| `./deploy.sh logs` | 查看所有服务日志 |
| `./deploy.sh status` | 查看服务状态 |
| `./deploy.sh clean` | 清理未使用的镜像和卷 |

---

## 方式二：独立部署

适用于：只更新某个服务，其他服务保持运行。

### 0. 创建共享网络

```bash
docker network create littlegrid-network
```

### 1. 部署 MySQL

```bash
docker run -d \
  --name littlegrid-mysql \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 3306:3306 \
  -v littlegrid-mysql-data:/var/lib/mysql \
  -v $(pwd)/backend/sql:/docker-entrypoint-initdb.d:ro \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_PWD \
  -e MYSQL_DATABASE=eladmin \
  -e TZ=Asia/Shanghai \
  mysql:8.0 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci \
  --default-authentication-plugin=mysql_native_password
```

### 2. 部署 Redis

```bash
docker run -d \
  --name littlegrid-redis \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 6379:6379 \
  -v littlegrid-redis-data:/data \
  redis:7-alpine \
  redis-server --requirepass your_redis_password_here --appendonly yes
```

### 3. 部署 Spring Boot Backend

```bash
# 构建镜像
cd backend
docker build -t littlegrid-backend:latest .

# 运行容器
docker run -d \
  --name littlegrid-backend \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 8000:8000 \
  -v $(pwd)/logs:/app/logs \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e SPRING_DATASOURCE_DRUID_URL="jdbc:p6spy:mysql://littlegrid-mysql:3306/eladmin?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true" \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=$MYSQL_PWD \
  -e REDIS_HOST=littlegrid-redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PWD=$REDIS_PWD \
  -e SERVER_PORT=8000 \
  littlegrid-backend:latest
```

### 4. 部署 Admin Web (Frontend)

```bash
# 构建镜像
cd admin-web
docker build -t littlegrid-frontend:latest .

# 运行容器
docker run -d \
  --name littlegrid-frontend \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 8001:8001 \
  --add-host=host.docker.internal:host-gateway \
  littlegrid-frontend:latest
```

---

## 管理脚本

创建 `manage.sh` 用于独立管理各服务：

```bash
#!/bin/bash
# ============================================================
# LittleGrid 服务管理脚本
# 用法: ./manage.sh {mysql|redis|backend|frontend|all|status|logs}
# ============================================================

set -e

# 配置（请先创建 .env 文件配置密码）
MYSQL_PWD=""  # 从 .env 读取
REDIS_PWD=""  # 从 .env 读取
NETWORK="littlegrid-network"
DB_NAME="eladmin"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}→ $1${NC}"; }

# 创建网络
create_network() {
  if ! docker network ls | grep -q $NETWORK; then
    docker network create $NETWORK
    print_success "网络 $NETWORK 创建成功"
  fi
}

# 部署 MySQL
deploy_mysql() {
  print_info "部署 MySQL..."
  docker stop littlegrid-mysql 2>/dev/null || true
  docker rm littlegrid-mysql 2>/dev/null || true
  
  docker run -d \
    --name littlegrid-mysql \
    --network $NETWORK \
    --restart unless-stopped \
    -p 3306:3306 \
    -v littlegrid-mysql-data:/var/lib/mysql \
    -v $(pwd)/backend/sql:/docker-entrypoint-initdb.d:ro \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_PWD \
    -e MYSQL_DATABASE=$DB_NAME \
    -e TZ=Asia/Shanghai \
    mysql:8.0 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_unicode_ci \
    --default-authentication-plugin=mysql_native_password
  
  print_success "MySQL 部署完成"
}

# 部署 Redis
deploy_redis() {
  print_info "部署 Redis..."
  docker stop littlegrid-redis 2>/dev/null || true
  docker rm littlegrid-redis 2>/dev/null || true
  
  docker run -d \
    --name littlegrid-redis \
    --network $NETWORK \
    --restart unless-stopped \
    -p 6379:6379 \
    -v littlegrid-redis-data:/data \
    redis:7-alpine \
    redis-server --requirepass $REDIS_PWD --appendonly yes
  
  print_success "Redis 部署完成"
}

# 部署 Backend
deploy_backend() {
  print_info "构建 Backend..."
  cd backend
  docker build -t littlegrid-backend:latest .
  cd ..
  
  print_info "部署 Backend..."
  docker stop littlegrid-backend 2>/dev/null || true
  docker rm littlegrid-backend 2>/dev/null || true
  
  docker run -d \
    --name littlegrid-backend \
    --network $NETWORK \
    --restart unless-stopped \
    -p 8000:8000 \
    -v $(pwd)/logs:/app/logs \
    -e SPRING_PROFILES_ACTIVE=prod \
    -e SPRING_DATASOURCE_DRUID_URL="jdbc:p6spy:mysql://littlegrid-mysql:3306/$DB_NAME?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true" \
    -e SPRING_DATASOURCE_USERNAME=root \
    -e SPRING_DATASOURCE_PASSWORD=$MYSQL_PWD \
    -e REDIS_HOST=littlegrid-redis \
    -e REDIS_PORT=6379 \
    -e REDIS_PWD=$REDIS_PWD \
    -e SERVER_PORT=8000 \
    littlegrid-backend:latest
  
  print_success "Backend 部署完成"
}

# 部署 Frontend
deploy_frontend() {
  print_info "构建 Frontend..."
  cd admin-web
  docker build -t littlegrid-frontend:latest .
  cd ..
  
  print_info "部署 Frontend..."
  docker stop littlegrid-frontend 2>/dev/null || true
  docker rm littlegrid-frontend 2>/dev/null || true
  
  docker run -d \
    --name littlegrid-frontend \
    --network $NETWORK \
    --restart unless-stopped \
    -p 8001:8001 \
    --add-host=host.docker.internal:host-gateway \
    littlegrid-frontend:latest
  
  print_success "Frontend 部署完成"
}

# 查看状态
show_status() {
  echo "服务状态:"
  docker ps --filter "name=littlegrid-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# 查看日志
show_logs() {
  local service=$1
  if [ -z "$service" ]; then
    docker compose logs -f
  else
    docker logs -f littlegrid-$service
  fi
}

# 主逻辑
case "$1" in
  mysql)
    create_network
    deploy_mysql
    ;;
  redis)
    create_network
    deploy_redis
    ;;
  backend)
    create_network
    deploy_backend
    ;;
  frontend)
    create_network
    deploy_frontend
    ;;
  all)
    create_network
    deploy_mysql
    deploy_redis
    deploy_backend
    deploy_frontend
    ;;
  status)
    show_status
    ;;
  logs)
    show_logs $2
    ;;
  restart)
    docker restart littlegrid-$2
    print_success "$2 重启完成"
    ;;
  stop)
    docker stop littlegrid-$2 2>/dev/null || true
    print_info "$2 已停止"
    ;;
  *)
    echo "用法: $0 {mysql|redis|backend|frontend|all|status|logs|restart|stop} [service]"
    echo ""
    echo "命令:"
    echo "  mysql      - 部署/更新 MySQL"
    echo "  redis      - 部署/更新 Redis"
    echo "  backend    - 部署/更新 Backend"
    echo "  frontend   - 部署/更新 Frontend"
    echo "  all        - 部署所有服务"
    echo "  status     - 查看服务状态"
    echo "  logs [svc] - 查看日志"
    echo "  restart    - 重启服务"
    echo "  stop       - 停止服务"
    exit 1
    ;;
esac
```

**使用方式：**

```bash
# 添加执行权限
chmod +x manage.sh

# 部署单个服务
./manage.sh mysql
./manage.sh redis
./manage.sh backend
./manage.sh frontend

# 部署所有服务
./manage.sh all

# 查看状态
./manage.sh status

# 查看日志
./manage.sh logs backend

# 重启服务
./manage.sh restart backend

# 停止服务
./manage.sh stop backend
```

---

## 更新服务

### 更新 Backend（代码更新后）

```bash
./manage.sh backend
```

或手动执行：

```bash
cd backend
docker build -t littlegrid-backend:latest .
docker stop littlegrid-backend && docker rm littlegrid-backend
# 然后运行 docker run 命令（见上文）
```

### 更新 Frontend（代码更新后）

```bash
./manage.sh frontend
```

### 更新 MySQL/Redis（通常不需要）

```bash
./manage.sh mysql
./manage.sh redis
```

---

## 故障排查

### 查看服务日志

```bash
# 使用管理脚本
./manage.sh logs backend
./manage.sh logs frontend

# 或直接使用 docker
docker logs -f littlegrid-backend
docker logs -f littlegrid-mysql
```

### 进入容器

```bash
# Backend
docker exec -it littlegrid-backend sh

# MySQL
docker exec -it littlegrid-mysql mysql -uroot -p

# Redis
docker exec -it littlegrid-redis redis-cli -a $REDIS_PWD
```

### 检查网络连接

```bash
# 进入 backend 容器测试连接
docker exec -it littlegrid-backend sh
ping littlegrid-mysql
ping littlegrid-redis
```

### 重启单个服务

```bash
docker restart littlegrid-backend
docker restart littlegrid-frontend
```

### 完全重置

```bash
# 停止并删除所有容器
docker stop littlegrid-mysql littlegrid-redis littlegrid-backend littlegrid-frontend
docker rm littlegrid-mysql littlegrid-redis littlegrid-backend littlegrid-frontend

# 重新部署
./manage.sh all
```

---

## 数据持久化

| 服务 | 数据位置 | 说明 |
|------|---------|------|
| MySQL | `littlegrid-mysql-data` 卷 | 数据库数据 |
| Redis | `littlegrid-redis-data` 卷 | 缓存数据 |
| Backend | `./logs` 目录 | 应用日志 |

**备份数据库：**

```bash
docker exec littlegrid-mysql mysqldump -uroot -p$MYSQL_PWD eladmin > backup_$(date +%Y%m%d).sql
```

**恢复数据库：**

```bash
cat backup.sql | docker exec -i littlegrid-mysql mysql -uroot -p$MYSQL_PWD eladmin
```

---

## 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| Admin 后台 | http://服务器IP:8001 | Vue 管理界面 |
| Backend API | http://服务器IP:8000 | 后端接口 |
| App API | http://服务器IP:8000/api/app/* | 移动端接口 |
| Swagger | http://服务器IP:8000/swagger-ui.html | API 文档 |
| Druid 监控 | http://服务器IP:8000/druid | 数据库监控 |