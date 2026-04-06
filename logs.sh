#!/bin/bash
# 日志查看脚本 - Little Grid 后端日志
# 用法: ./logs.sh [命令] [参数]

LOG_DIR="backend/logs"
APP_LOG="$LOG_DIR/grid-app.log"
ERROR_LOG="$LOG_DIR/grid-app-error.log"
CONTAINER_NAME="littlegrid-backend"

show_help() {
    echo "=========================================="
    echo "  Little Grid 日志查看工具"
    echo "=========================================="
    echo ""
    echo "用法: ./logs.sh [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  app          实时查看应用日志"
    echo "  error        实时查看错误日志"
    echo "  all          实时查看应用和错误日志"
    echo "  trace <id>   按 TraceId 查找日志"
    echo "  search <关键词>  搜索日志内容"
    echo "  today        查看今天的请求日志"
    echo "  docker       查看 Docker 容器日志"
    echo "  ls           列出日志文件"
    echo "  help         显示帮助信息"
    echo ""
    echo "示例:"
    echo "  ./logs.sh app              # 实时查看应用日志"
    echo "  ./logs.sh trace abc123     # 查找 TraceId 为 abc123 的日志"
    echo "  ./logs.sh search 登录      # 搜索包含\"登录\"的日志"
    echo ""
}

check_log_dir() {
    if [ ! -d "$LOG_DIR" ]; then
        echo "错误: 日志目录不存在: $LOG_DIR"
        echo "提示: 请先启动后端服务生成日志文件"
        exit 1
    fi
}

case "$1" in
    "app")
        check_log_dir
        echo ">>> 实时查看应用日志 (Ctrl+C 退出)"
        echo ""
        tail -f "$APP_LOG"
        ;;

    "error")
        check_log_dir
        echo ">>> 实时查看错误日志 (Ctrl+C 退出)"
        echo ""
        tail -f "$ERROR_LOG"
        ;;

    "all")
        check_log_dir
        echo ">>> 实时查看应用和错误日志 (Ctrl+C 退出)"
        echo ""
        tail -f "$APP_LOG" "$ERROR_LOG"
        ;;

    "trace")
        if [ -z "$2" ]; then
            echo "错误: 请提供 TraceId"
            echo "用法: ./logs.sh trace <TraceId>"
            echo "示例: ./logs.sh trace abc123"
            exit 1
        fi
        check_log_dir
        echo ">>> 查找 TraceId: $2"
        echo "=========================================="
        grep -A 5 -B 2 "\[$2\]" "$APP_LOG" 2>/dev/null || echo "未找到相关日志"
        ;;

    "search")
        if [ -z "$2" ]; then
            echo "错误: 请提供搜索关键词"
            echo "用法: ./logs.sh search <关键词>"
            echo "示例: ./logs.sh search 登录"
            exit 1
        fi
        check_log_dir
        echo ">>> 搜索关键词: $2"
        echo "=========================================="
        grep -n "$2" "$APP_LOG" 2>/dev/null | tail -50 || echo "未找到相关日志"
        ;;

    "today")
        check_log_dir
        TODAY=$(date +"%Y-%m-%d")
        echo ">>> 今天的请求日志 ($TODAY)"
        echo "=========================================="
        grep "请求开始" "$APP_LOG" 2>/dev/null | grep "$TODAY" | tail -20 || echo "今天暂无请求日志"
        ;;

    "docker")
        echo ">>> Docker 容器日志 (Ctrl+C 退出)"
        echo ""
        docker logs -f --tail 100 "$CONTAINER_NAME" 2>/dev/null || echo "错误: 容器未运行或不存在: $CONTAINER_NAME"
        ;;

    "ls")
        check_log_dir
        echo ">>> 日志文件列表"
        echo "=========================================="
        ls -lh "$LOG_DIR"/
        echo ""
        echo "文件大小:"
        du -sh "$LOG_DIR"/*
        ;;

    "help"|"-h"|"--help"|"")
        show_help
        ;;

    *)
        echo "未知命令: $1"
        echo ""
        show_help
        ;;
esac