# LittleGrid Docker 独立部署

## 环境配置

创建 `.env` 文件：

```bash
DB_ROOT_PASSWORD=your_mysql_password_here
DB_NAME=eladmin
REDIS_PWD=your_redis_password_here
```

## 部署命令

**部署顺序：MySQL → Redis → Backend → Frontend**

```bash
# 1. 部署 MySQL
./manage.sh mysql

# 2. 部署 Redis
./manage.sh redis

# 3. 部署 Spring Boot Backend
./manage.sh backend

# 4. 部署 Admin Web Frontend
./manage.sh frontend
```

## 管理命令

```bash
# 查看服务状态
./manage.sh status

# 查看 Spring Boot 日志
./manage.sh logs

# 重启服务
./manage.sh restart backend

# 停止服务
./manage.sh stop backend   # 停止单个服务
./manage.sh stop           # 停止所有服务
```

## 访问地址

| 服务 | 地址 |
|------|------|
| Admin 后台 | http://服务器IP:8001 |
| Backend API | http://服务器IP:8000 |

## 手动部署命令

如不使用脚本，可手动执行：

### MySQL

```bash
docker run -d \
  --name littlegrid-mysql \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 3306:3306 \
  -v littlegrid-mysql-data:/var/lib/mysql \
  -v $(pwd)/backend/sql:/docker-entrypoint-initdb.d:ro \
  -e MYSQL_ROOT_PASSWORD=your_password \
  -e MYSQL_DATABASE=eladmin \
  -e TZ=Asia/Shanghai \
  mysql:8.0 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_unicode_ci
```

### Redis

```bash
docker run -d \
  --name littlegrid-redis \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 6379:6379 \
  -v littlegrid-redis-data:/data \
  redis:7-alpine \
  redis-server --requirepass your_password --appendonly yes
```

### Backend

```bash
cd backend && docker build -t littlegrid-backend:latest .
docker run -d \
  --name littlegrid-backend \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 8000:8000 \
  -v $(pwd)/logs:/app/logs \
  -e SPRING_DATASOURCE_DRUID_URL="jdbc:p6spy:mysql://littlegrid-mysql:3306/eladmin?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true" \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=your_password \
  -e REDIS_HOST=littlegrid-redis \
  -e REDIS_PWD=your_password \
  littlegrid-backend:latest
```

### Frontend

```bash
cd admin-web && docker build -t littlegrid-frontend:latest .
docker run -d \
  --name littlegrid-frontend \
  --network littlegrid-network \
  --restart unless-stopped \
  -p 8001:8001 \
  --add-host=host.docker.internal:host-gateway \
  littlegrid-frontend:latest
```

### 查看日志

```bash
docker logs -f littlegrid-backend
```