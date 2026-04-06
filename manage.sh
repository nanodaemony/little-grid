#!/bin/bash
# ============================================================
# LittleGrid Docker 独立部署脚本
# 用法: ./manage.sh {mysql|redis|backend|frontend|logs|status|stop|restart}
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 数据存储目录（服务器固定路径）
DATA_DIR="/home/nano/littlegrid-data"

# 配置变量（从 .env 读取）
MYSQL_PWD=""
REDIS_PWD=""
DB_NAME="eladmin"
NETWORK="littlegrid-network"

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
  if [ -f "$SCRIPT_DIR/.env" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "$line" ]] && continue
      key="${line%%=*}"
      value="${line#*=}"
      value="${value%\"}"; value="${value#\"}"
      value="${value%\'}"; value="${value#\'}"
      case "$key" in
        DB_ROOT_PASSWORD) MYSQL_PWD="$value" ;;
        REDIS_PWD) REDIS_PWD="$value" ;;
        DB_NAME) DB_NAME="$value" ;;
      esac
    done < "$SCRIPT_DIR/.env"
  fi
}

# 创建网络
create_network() {
  if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
    docker network create "$NETWORK"
    print_success "网络 $NETWORK 创建成功"
  fi
}

# 部署 MySQL
deploy_mysql() {
  print_info "部署 MySQL..."
  docker stop littlegrid-mysql 2>/dev/null || true
  docker rm littlegrid-mysql 2>/dev/null || true

  mkdir -p "$DATA_DIR/mysql"

  docker run -d \
    --name littlegrid-mysql \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p 3306:3306 \
    -v "$DATA_DIR/mysql:/var/lib/mysql" \
    -v "$SCRIPT_DIR/backend/sql:/docker-entrypoint-initdb.d:ro" \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_PWD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -e TZ=Asia/Shanghai \
    mysql:8.0 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_unicode_ci \
    --default-authentication-plugin=mysql_native_password

  print_success "MySQL 部署完成 (端口: 3306, 数据: $DATA_DIR/mysql)"
}

# 部署 Redis
deploy_redis() {
  print_info "部署 Redis..."
  docker stop littlegrid-redis 2>/dev/null || true
  docker rm littlegrid-redis 2>/dev/null || true

  mkdir -p "$DATA_DIR/redis"

  docker run -d \
    --name littlegrid-redis \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p 6379:6379 \
    -v "$DATA_DIR/redis:/data" \
    redis:7-alpine \
    redis-server --requirepass "$REDIS_PWD" --appendonly yes

  print_success "Redis 部署完成 (端口: 6379, 数据: $DATA_DIR/redis)"
}

# 部署 Backend
deploy_backend() {
  print_info "构建 Backend..."
  docker build -t littlegrid-backend:latest "$SCRIPT_DIR/backend"

  print_info "部署 Backend..."
  docker stop littlegrid-backend 2>/dev/null || true
  docker rm littlegrid-backend 2>/dev/null || true

  mkdir -p "$SCRIPT_DIR/logs"

  docker run -d \
    --name littlegrid-backend \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p 8000:8000 \
    -v "$SCRIPT_DIR/logs:/app/logs" \
    -e SPRING_PROFILES_ACTIVE=prod \
    -e SPRING_DATASOURCE_DRUID_URL="jdbc:p6spy:mysql://littlegrid-mysql:3306/$DB_NAME?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true" \
    -e SPRING_DATASOURCE_USERNAME=root \
    -e SPRING_DATASOURCE_PASSWORD="$MYSQL_PWD" \
    -e REDIS_HOST=littlegrid-redis \
    -e REDIS_PORT=6379 \
    -e REDIS_PWD="$REDIS_PWD" \
    -e SERVER_PORT=8000 \
    littlegrid-backend:latest

  print_success "Backend 部署完成 (端口: 8000)"
}

# 部署 Frontend
deploy_frontend() {
  print_info "构建 Frontend..."
  docker build -t littlegrid-frontend:latest "$SCRIPT_DIR/admin-web"

  print_info "部署 Frontend..."
  docker stop littlegrid-frontend 2>/dev/null || true
  docker rm littlegrid-frontend 2>/dev/null || true

  docker run -d \
    --name littlegrid-frontend \
    --network "$NETWORK" \
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
  for service in mysql redis backend frontend; do
    if docker ps --filter "name=littlegrid-$service" --filter "status=running" --format "{{.Names}}" 2>/dev/null | grep -q .; then
      printf "%-25s %b\n" "littlegrid-$service" "${GREEN}运行中${NC}"
    else
      printf "%-25s %b\n" "littlegrid-$service" "${RED}未运行${NC}"
    fi
  done
}

# 查看 Backend 日志
show_logs() {
  echo ">>> Spring Boot 日志 (Ctrl+C 退出)"
  echo ""
  docker logs -f --tail 100 littlegrid-backend 2>/dev/null || print_error "Backend 服务未运行"
}

# 停止服务
stop_service() {
  local service=$1
  if [ -z "$service" ]; then
    for svc in frontend backend redis mysql; do
      docker stop "littlegrid-$svc" 2>/dev/null || true
    done
    print_success "所有服务已停止"
  else
    docker stop "littlegrid-$service" 2>/dev/null && print_success "$service 已停止" || print_error "$service 未运行"
  fi
}

# 重启服务
restart_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo "用法: $0 restart {mysql|redis|backend|frontend}"
    exit 1
  fi
  docker restart "littlegrid-$service" 2>/dev/null && print_success "$service 重启完成" || print_error "$service 不存在"
}

# 显示帮助
show_help() {
  cat << 'EOF'
===================================
  LittleGrid Docker 独立部署
===================================

用法: ./manage.sh <命令> [参数]

命令:
  mysql       部署 MySQL
  redis       部署 Redis
  backend     部署 Spring Boot Backend
  frontend    部署 Admin Web Frontend
  logs        查看 Spring Boot 日志
  status      查看服务状态
  stop        停止服务 [可选: 指定服务名]
  restart     重启服务 (需指定服务名)

部署顺序: mysql → redis → backend → frontend

示例:
  ./manage.sh mysql       # 部署 MySQL
  ./manage.sh backend     # 部署 Backend
  ./manage.sh logs        # 查看日志
  ./manage.sh status      # 查看状态
EOF
}

# 主逻辑
load_env

case "$1" in
  mysql)    create_network; deploy_mysql ;;
  redis)    create_network; deploy_redis ;;
  backend)  create_network; deploy_backend ;;
  frontend) create_network; deploy_frontend ;;
  logs)     show_logs ;;
  status)   show_status ;;
  stop)     stop_service "$2" ;;
  restart)  restart_service "$2" ;;
  help|--help|-h) show_help ;;
  *)        show_help; exit 1 ;;
esac