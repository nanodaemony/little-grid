#!/bin/bash

# LittleGrid Docker 部署脚本
# 用途：快速部署、更新代码、重启服务

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_DIR="/home/nano/littlegrid"
cd "$PROJECT_DIR"

# 函数：打印帮助信息
print_help() {
    echo "================================"
    echo "  LittleGrid Docker 部署脚本"
    echo "================================"
    echo ""
    echo "用法: ./deploy.sh [命令]"
    echo ""
    echo "命令:"
    echo "  start        - 首次部署并启动所有服务"
    echo "  build        - 重新构建并启动服务"
    echo "  update       - 拉取最新代码并重新构建"
    echo "  restart      - 重启所有服务"
    echo "  stop         - 停止所有服务"
    echo "  logs         - 查看所有服务日志"
    echo "  status       - 查看服务状态"
    echo "  clean        - 清理未使用的镜像和卷"
    echo "  help         - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./deploy.sh start    # 首次部署"
    echo "  ./deploy.sh update   # 更新代码并重启"
    echo "  ./deploy.sh logs     # 查看日志"
}

# 函数：打印成功信息
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 函数：打印警告信息
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 函数：打印错误信息
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# 函数：检查环境
check_env() {
    if [ ! -f .env ]; then
        print_error ".env 文件不存在，请先创建配置文件"
        exit 1
    fi
    print_success "环境配置检查通过"
}

# 函数：检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        exit 1
    fi
    print_success "Docker 已安装: $(docker --version)"
}

# 函数：首次部署
deploy_start() {
    print_warning "开始首次部署..."
    check_env
    check_docker

    echo "拉取最新代码..."
    git pull

    echo "构建并启动所有服务..."
    docker compose up -d --build

    echo "等待服务启动..."
    sleep 10

    echo "服务状态:"
    docker compose ps

    print_success "部署完成！"
    echo ""
    echo "访问地址:"
    echo "  - 前端: http://$(hostname -I | awk '{print $1}'):8001"
    echo "  - 后端: http://$(hostname -I | awk '{print $1}'):8000"
}

# 函数：重新构建
deploy_build() {
    print_warning "重新构建服务..."
    docker compose up -d --build
    print_success "构建完成"
    docker compose ps
}

# 函数：更新代码
deploy_update() {
    print_warning "更新代码..."
    echo "拉取最新代码..."
    git pull

    echo "重新构建并启动..."
    docker compose up -d --build

    print_success "更新完成"
    docker compose ps
}

# 函数：重启服务
deploy_restart() {
    print_warning "重启服务..."
    docker compose restart
    print_success "服务已重启"
    docker compose ps
}

# 函数：停止服务
deploy_stop() {
    print_warning "停止服务..."
    docker compose stop
    print_success "服务已停止"
}

# 函数：查看日志
deploy_logs() {
    print_warning "查看服务日志 (Ctrl+C 退出)..."
    docker compose logs -f
}

# 函数：查看状态
deploy_status() {
    echo "服务状态:"
    docker compose ps
    echo ""
    echo "容器详情:"
    docker compose top
}

# 函数：清理
deploy_clean() {
    print_warning "清理未使用的镜像和卷..."
    read -p "确认清理? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        docker system prune -a --volumes
        print_success "清理完成"
    else
        print_warning "已取消操作"
    fi
}

# 主逻辑
main() {
    case "${1:-help}" in
        start)
            deploy_start
            ;;
        build)
            deploy_build
            ;;
        update)
            deploy_update
            ;;
        restart)
            deploy_restart
            ;;
        stop)
            deploy_stop
            ;;
        logs)
            deploy_logs
            ;;
        status)
            deploy_status
            ;;
        clean)
            deploy_clean
            ;;
        help|--help|-h)
            print_help
            ;;
        *)
            print_error "未知命令: $1"
            print_help
            exit 1
            ;;
    esac
}

main "$@"
