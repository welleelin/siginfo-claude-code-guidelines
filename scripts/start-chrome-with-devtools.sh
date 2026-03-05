#!/bin/bash
# Chrome DevTools 启动脚本
# 用法：./scripts/start-chrome-with-devtools.sh [端口号]

set -e

PORT=${1:-9222}
PROFILE_DIR="/tmp/chrome-dev-profile-${PORT}"

echo "🚀 启动 Chrome DevTools..."
echo "   端口：${PORT}"
echo "   用户数据目录：${PROFILE_DIR}"

# 检测操作系统和 Chrome 路径
case "$(uname -s)" in
  Darwin)
    # macOS
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    if [ ! -f "$CHROME_PATH" ]; then
      # 尝试 Chrome Canary
      CHROME_PATH="/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
    fi
    ;;
  Linux)
    CHROME_PATH="/usr/bin/google-chrome"
    if [ ! -f "$CHROME_PATH" ]; then
      CHROME_PATH="/usr/bin/chromium-browser"
    fi
    ;;
  *)
    echo "❌ 不支持的操作系统"
    exit 1
    ;;
esac

# 检查 Chrome 是否存在
if [ ! -f "$CHROME_PATH" ]; then
  echo "❌ Chrome 未安装在预期位置"
  echo "   请安装 Google Chrome 或修改脚本中的 CHROME_PATH 变量"
  exit 1
fi

echo "✅ Chrome 路径：${CHROME_PATH}"

# 清理旧的配置文件
if [ -d "$PROFILE_DIR" ]; then
  echo "🧹 清理旧的用户配置..."
  rm -rf "$PROFILE_DIR"
fi

mkdir -p "$PROFILE_DIR"

# 启动 Chrome
echo "🔍 启动 Chrome 并开启 DevTools 协议..."
"$CHROME_PATH" \
  --remote-debugging-port="${PORT}" \
  --user-data-dir="${PROFILE_DIR}" \
  --no-first-run \
  --no-default-browser-check \
  --disable-gpu \
  --disable-dev-shm-usage \
  --disable-extensions \
  --disable-background-networking \
  --disable-sync \
  --metrics-recording-only \
  --no-default-browser-check \
  --force-device-scale-factor=1 \
  --window-size=1920,1080 &

CHROME_PID=$!
echo "✅ Chrome 已启动 (PID: ${CHROME_PID})"

# 等待 Chrome 启动
echo "⏳ 等待 Chrome 启动..."
sleep 2

# 验证 DevTools 端口
if curl -s "http://localhost:${PORT}/json/version" > /dev/null; then
  echo "✅ DevTools 协议已就绪"
  echo ""
  echo "📊 调试地址："
  echo "   - 版本信息：http://localhost:${PORT}/json/version"
  echo "   - 目标列表：http://localhost:${PORT}/json/list"
  echo ""
  echo "💡 提示:"
  echo "   - 按 Ctrl+C 停止 Chrome"
  echo "   - Chrome PID: ${CHROME_PID}"
else
  echo "❌ DevTools 端口响应失败"
  exit 1
fi

# 等待用户中断
wait $CHROME_PID
