#!/bin/bash
# Chrome DevTools MCP + Playwright 快速启动脚本

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   Chrome DevTools MCP + Playwright 深度测试启动            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# 检查 Chrome
case "$(uname -s)" in
  Darwin)
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    ;;
  Linux)
    CHROME_PATH="/usr/bin/google-chrome"
    ;;
  *)
    echo "❌ 不支持的操作系统"
    exit 1
    ;;
esac

if [ ! -f "$CHROME_PATH" ]; then
  echo "❌ Chrome 未找到，请安装 Google Chrome"
  exit 1
fi

# 端口配置
DEVTOOLS_PORT=9222
PLAYWRIGHT_PORT=9223

echo "📦 检查 MCP 配置..."
cat ~/.claude/mcp.json | jq '.mcpServers' 2>/dev/null || echo "⚠️  无法读取 MCP 配置"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "启动方式 1: 基本模式 (推荐)"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "直接使用 npx 运行 Chrome DevTools MCP:"
echo '  npx -y chrome-devtools-mcp@latest'
echo ""
echo "这将在有头模式下启动 Chrome，可以直接看到浏览器操作。"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "启动方式 2: 手动启动 Chrome + DevTools 端口"
echo "═══════════════════════════════════════════════════════════"
echo ""
read -p "是否手动启动 Chrome? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  PROFILE_DIR="/tmp/chrome-mcp-profile"
  rm -rf "$PROFILE_DIR"
  mkdir -p "$PROFILE_DIR"

  "$CHROME_PATH" \
    --remote-debugging-port="$DEVTOOLS_PORT" \
    --user-data-dir="$PROFILE_DIR" \
    --no-first-run \
    --no-default-browser-check \
    --disable-gpu \
    --disable-dev-shm-usage &

  CHROME_PID=$!
  echo "✅ Chrome 已启动 (PID: $CHROME_PID)"
  echo "📊 调试地址：http://localhost:$DEVTOOLS_PORT/json/version"
  echo ""
  echo "按 Ctrl+C 停止 Chrome"
  wait $CHROME_PID
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "使用 Playwright 进行测试"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "运行测试命令:"
echo "  npx playwright test"
echo ""
echo "运行深度测试示例:"
echo "  npx playwright test examples/deep-testing-with-devtools.test.ts"
echo ""
