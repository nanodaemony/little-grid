#!/bin/bash
# ============================================================
# LittleGrid 服务管理脚本
# 用法: ./manage.sh {mysql|redis|backend|frontend|all|status|logs}
# ============================================================

set -e

# 配置 - 从 .env 文件读取或使用默认值
MYSQL_PWD="${DB_ROOT_PASSWORD:-lSgDPBBPtp4YQdTYOACn}"
REDIS_PWD="${REDIS_PWD:-H4FehnB2wqMzW3jA}"
NETWORK="littlegrid-network"
DB_NAME="${DB_NAME:-eladmin}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}→ $1${NC}"; }

# 加载 .env 配置
load_env() {
  if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    MYSQL_PWD="${DB_ROOT_PASSWORD:-$MYSQL_PWD}"
    REDIS_PWD="${REDIS_PWD:-$REDIS_PWD}"
    DB_NAME="${DB_NAME:-eladmin}"
  fi
}

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

  print_success "MySQL 部署完成 (端口: 3306)"
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

  print_success "Redis 部署完成 (端口: 6379)"
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

  print_success "Backend 部署完成 (端口: 8000)"
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

  print_success "Frontend 部署完成 (端口: 8001)"
}

# 查看状态
show_status() {
  echo "==================================="
  echo "  LittleGrid 服务状态"
  echo "==================================="
  docker ps --filter "name=littlegrid-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "没有运行中的服务"
}

# 查看日志
show_logs() {
  local service=$1
  if [ -z "$service" ]; then
    echo "用法: $0 logs {mysql|redis|backend|frontend}"
    exit 1
  fi
  docker logs -f littlegrid-$service
}

# 停止服务
stop_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo "停止所有服务..."
    docker stop littlegrid-mysql littlegrid-redis littlegrid-backend littlegrid-frontend 2>/dev/null || true
    print_success "所有服务已停止"
  else
    docker stop littlegrid-$service 2>/dev/null || true
    print_success "$service 已停止"
  fi
}

# 重启服务
restart_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo "用法: $0 restart {mysql|redis|backend|frontend}"
    exit 1
  fi
  docker restart littlegrid-$service
  print_success "$service 重启完成"
}

# 清理
cleanup() {
  echo "清理未使用的资源..."
  docker system prune -f
  print_success "清理完成"
}

# 显示帮助
show_help() {
  echo "==================================="
  echo "  LittleGrid 服务管理脚本"
  echo "==================================="
  echo ""
  echo "用法: $0 <command> [service]"
  echo ""
  echo "命令:"
  echo "  mysql       部署/更新 MySQL"
  echo "  redis       部署/更新 Redis"
  echo "  backend     部署/更新 Backend"
  echo "  frontend    部署/更新 Frontend"
  echo "  all         部署所有服务"
  echo "  status      查看服务状态"
  echo "  logs        查看日志 (需指定服务)"
  echo "  restart     重启服务 (需指定服务)"
  echo "  stop        停止服务 [可选: 指定服务名]"
  echo "  cleanup     清理未使用的Docker资源"
  echo ""
  echo "示例:"
  echo "  $0 backend      # 更新后端"
  echo "  $0 logs backend # 查看后端日志"
  echo "  $0 restart mysql # 重启MySQL"
  echo "  $0 stop         # 停止所有服务"
}

# 主逻辑
load_env

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
    sleep 10  # 等待 MySQL 启动
    deploy_redis
    deploy_backend
    deploy_frontend
    show_status
    ;;
  status)
    show_status
    ;;
  logs)
    show_logs $2
    ;;
  restart)
    restart_service $2
    ;;
  stop)
    stop_service $2
    ;;
  cleanup)
    cleanup
    ;;
  help|--help|-h)
    show_help
    ;;
  *)
    show_help
    exit 1
    ;;
esac