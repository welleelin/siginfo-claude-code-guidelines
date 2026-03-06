#!/bin/bash

# siginfo-claude-code-guidelines 预览服务器脚本
# 用于在浏览器中预览 Web UI 和 Web PPT 展示页面

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHOWCASE_DIR="$SCRIPT_DIR/docs/capability-showcase"
PORT=8080

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "  siginfo-claude-code-guidelines 预览服务器"
echo "========================================"
echo ""

# 检查目录是否存在
if [ ! -d "$SHOWCASE_DIR" ]; then
    echo -e "${RED}错误：展示目录不存在${NC}"
    echo "路径：$SHOWCASE_DIR"
    exit 1
fi

# 检查 Python 是否安装
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
elif command -v python &> /dev/null; then
    PYTHON_CMD=python
else
    echo -e "${RED}错误：未找到 Python${NC}"
    echo "请安装 Python 3.x"
    exit 1
fi

echo -e "${GREEN}✓ 展示目录：${NC}$SHOWCASE_DIR"
echo -e "${GREEN}✓ Python 版本：${NC}$($PYTHON_CMD --version)"
echo ""

# 检查文件
echo -e "${BLUE}可用的展示页面：${NC}"
echo ""
if [ -f "$SHOWCASE_DIR/index.html" ]; then
    echo "  [1] Web UI 展示页面（含专家矩阵）"
    echo "      http://localhost:$PORT/index.html"
fi
if [ -f "$SHOWCASE_DIR/presentation.html" ]; then
    echo "  [2] Web PPT 幻灯片 (10 页演示)"
    echo "      http://localhost:$PORT/presentation.html"
fi
echo ""

# 自动打开浏览器
open_browser() {
    local url=$1
    case "$(uname -s)" in
        Darwin)
            open "$url"
            ;;
        Linux)
            if command -v xdg-open &> /dev/null; then
                xdg-open "$url"
            elif command -v sensible-browser &> /dev/null; then
                sensible-browser "$url"
            fi
            ;;
        MINGW*|CYGWIN*|MSYS*)
            start "$url"
            ;;
    esac
}

# 选择要打开的页面
echo -e "${YELLOW}请选择要预览的页面：${NC}"
echo "  1 - Web UI 展示页面（含专家矩阵）"
echo "  2 - Web PPT 幻灯片"
echo "  3 - 两者都打开"
echo "  q - 退出"
echo ""
read -p "请输入选项 (1/2/3/q): " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}启动预览服务器...${NC}"
        echo -e "${BLUE}Web UI 页面：${NC}http://localhost:$PORT/index.html"
        echo ""
        echo "按 Ctrl+C 停止服务器"
        echo ""
        sleep 2
        open_browser "http://localhost:$PORT/index.html"
        cd "$SHOWCASE_DIR" && $PYTHON_CMD -m http.server $PORT
        ;;
    2)
        echo ""
        echo -e "${GREEN}启动预览服务器...${NC}"
        echo -e "${BLUE}Web PPT 页面：${NC}http://localhost:$PORT/presentation.html"
        echo ""
        echo "按 Ctrl+C 停止服务器"
        echo ""
        sleep 2
        open_browser "http://localhost:$PORT/presentation.html"
        cd "$SHOWCASE_DIR" && $PYTHON_CMD -m http.server $PORT
        ;;
    3)
        echo ""
        echo -e "${GREEN}启动预览服务器...${NC}"
        echo -e "${BLUE}Web UI 页面：${NC}http://localhost:$PORT/index.html"
        echo -e "${BLUE}Web PPT 页面：${NC}http://localhost:$PORT/presentation.html"
        echo ""
        echo "按 Ctrl+C 停止服务器"
        echo ""
        sleep 2
        open_browser "http://localhost:$PORT/index.html"
        sleep 1
        open_browser "http://localhost:$PORT/presentation.html"
        cd "$SHOWCASE_DIR" && $PYTHON_CMD -m http.server $PORT
        ;;
    q|Q)
        echo "退出"
        exit 0
        ;;
    *)
        echo -e "${RED}无效的选项${NC}"
        exit 1
        ;;
esac
