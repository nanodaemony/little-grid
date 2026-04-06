#!/bin/bash
# ============================================================
# LittleGrid 服务管理脚本
# 用法: ./manage.sh {mysql|redis|backend|frontend|all|status|logs}
# ============================================================

set -e

# 获取脚本所在目录（支持软链接）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 默认配置
DEFAULT_MYSQL_PWD="lSgDPBBPtp4YQdTYOACn"
DEFAULT_REDIS_PWD="H4FehnB2wqMzW3jA"
DEFAULT_DB_NAME="eladmin"

# 配置变量（将被 .env 覆盖）
MYSQL_PWD="$DEFAULT_MYSQL_PWD"
REDIS_PWD="$DEFAULT_REDIS_PWD"
DB_NAME="$DEFAULT_DB_NAME"
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
    # 安全加载 .env，处理带空格的值
    while IFS= read -r line || [ -n "$line" ]; do
      # 跳过注释和空行
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "$line" ]] && continue

      # 提取变量名和值
      key="${line%%=*}"
      value="${line#*=}"

      # 移除可能的引号
      value="${value%\"}"
      value="${value#\"}"
      value="${value%\'}"
      value="${value#\'}"

      # 设置变量
      case "$key" in
        DB_ROOT_PASSWORD) MYSQL_PWD="$value" ;;
        REDIS_PWD) REDIS_PWD="$value" ;;
        DB_NAME) DB_NAME="$value" ;;
      esac
    done < "$SCRIPT_DIR/.env"

    print_info "已加载 .env 配置"
  fi
}

# 创建网络
create_network() {
  if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
    docker network create "$NETWORK"
    print_success "网络 $NETWORK 创建成功"
  fi
}

# 等待 MySQL 就绪
wait_for_mysql() {
  print_info "等待 MySQL 启动..."
  local max_attempts=30
  local attempt=0

  while [ $attempt -lt $max_attempts ]; do
    if docker exec littlegrid-mysql mysqladmin ping -h localhost -u root -p"$MYSQL_PWD" --silent 2>/dev/null; then
      print_success "MySQL 已就绪"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  print_error "MySQL 启动超时"
  return 1
}

# 部署 MySQL
deploy_mysql() {
  print_info "部署 MySQL..."
  docker stop littlegrid-mysql 2>/dev/null || true
  docker rm littlegrid-mysql 2>/dev/null || true

  docker run -d \
    --name littlegrid-mysql \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p 3306:3306 \
    -v littlegrid-mysql-data:/var/lib/mysql \
    -v "$SCRIPT_DIR/backend/sql:/docker-entrypoint-initdb.d:ro" \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_PWD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -e TZ=Asia/Shanghai \
    mysql:8.0 \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_unicode_ci \
    --default-authentication-plugin=mysql_native_password

  print_success "MySQL 部署完成 (端口: 3306)"

  # 等待 MySQL 就绪
  wait_for_mysql
}

# 部署 Redis
deploy_redis() {
  print_info "部署 Redis..."
  docker stop littlegrid-redis 2>/dev/null || true
  docker rm littlegrid-redis 2>/dev/null || true

  docker run -d \
    --name littlegrid-redis \
    --network "$NETWORK" \
    --restart unless-stopped \
    -p 6379:6379 \
    -v littlegrid-redis-data:/data \
    redis:7-alpine \
    redis-server --requirepass "$REDIS_PWD" --appendonly yes

  print_success "Redis 部署完成 (端口: 6379)"
}

# 部署 Backend
deploy_backend() {
  print_info "构建 Backend..."
  docker build -t littlegrid-backend:latest "$SCRIPT_DIR/backend"

  print_info "部署 Backend..."
  docker stop littlegrid-backend 2>/dev/null || true
  docker rm littlegrid-backend 2>/dev/null || true

  # 创建日志目录
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

  local running=0
  for service in mysql redis backend frontend; do
    if docker ps --filter "name=littlegrid-$service" --filter "status=running" --format "{{.Names}}" 2>/dev/null | grep -q .; then
      status="${GREEN}运行中${NC}"
      running=$((running + 1))
    else
      status="${RED}未运行${NC}"
    fi
    printf "%-25s %b\n" "littlegrid-$service" "$status"
  done

  echo ""
  echo "运行中服务: $running/4"
}

# 查看日志
show_logs() {
  local service=$1
  if [ -z "$service" ]; then
    echo "用法: $0 logs {mysql|redis|backend|frontend}"
    exit 1
  fi

  if ! docker ps --filter "name=littlegrid-$service" --format "{{.Names}}" 2>/dev/null | grep -q .; then
    print_error "服务 littlegrid-$service 未运行"
    exit 1
  fi

  docker logs -f "littlegrid-$service"
}

# 停止服务
stop_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo "停止所有服务..."
    for svc in frontend backend redis mysql; do
      docker stop "littlegrid-$svc" 2>/dev/null || true
    done
    print_success "所有服务已停止"
  else
    if docker stop "littlegrid-$service" 2>/dev/null; then
      print_success "$service 已停止"
    else
      print_error "$service 未在运行"
    fi
  fi
}

# 重启服务
restart_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo "用法: $0 restart {mysql|redis|backend|frontend}"
    exit 1
  fi

  if docker restart "littlegrid-$service" 2>/dev/null; then
    print_success "$service 重启完成"
  else
    print_error "$service 不存在或未运行"
    exit 1
  fi
}

# 清理
cleanup() {
  echo "清理未使用的 Docker 资源..."
  docker system prune -f
  print_success "清理完成"
}

# 显示帮助
show_help() {
  cat << 'EOF'
===================================
  LittleGrid 服务管理脚本
===================================

用法: ./manage.sh <command> [service]

命令:
  mysql       部署/更新 MySQL
  redis       部署/更新 Redis
  backend     部署/更新 Backend
  frontend    部署/更新 Frontend
  all         部署所有服务
  status      查看服务状态
  logs        查看日志 (需指定服务)
  restart     重启服务 (需指定服务)
  stop        停止服务 [可选: 指定服务名]
  cleanup     清理未使用的Docker资源

示例:
  ./manage.sh backend       # 更新后端
  ./manage.sh logs backend  # 查看后端日志
  ./manage.sh restart mysql # 重启MySQL
  ./manage.sh stop          # 停止所有服务
EOF
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
    deploy_redis
    deploy_backend
    deploy_frontend
    echo ""
    show_status
    ;;
  status)
    show_status
    ;;
  logs)
    show_logs "$2"
    ;;
  restart)
    restart_service "$2"
    ;;
  stop)
    stop_service "$2"
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