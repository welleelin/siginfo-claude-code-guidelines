#!/bin/bash
# Chrome DevTools MCP + Playwright 集成安装脚本

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   Chrome DevTools MCP + Playwright 集成安装               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
  if command -v "$1" &> /dev/null; then
    echo -e "${GREEN}✓${NC} $2 已安装"
    return 0
  else
    echo -e "${RED}✗${NC} $2 未安装"
    return 1
  fi
}

# 步骤 1: 检查前置条件
echo "═══════════════════════════════════════════════════════════"
echo "步骤 1: 检查前置条件"
echo "═══════════════════════════════════════════════════════════"

check_command node "Node.js"
check_command npm "npm"
check_command python3 "Python 3"

# 检查 Chrome
case "$(uname -s)" in
  Darwin)
    if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
      echo -e "${GREEN}✓${NC} Google Chrome 已安装"
    elif [ -f "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary" ]; then
      echo -e "${YELLOW}⚠${NC} 仅找到 Chrome Canary"
    else
      echo -e "${RED}✗${NC} Google Chrome 未安装"
      echo "   请下载：https://www.google.com/chrome/"
    fi
    ;;
  Linux)
    if command -v google-chrome &> /dev/null || command -v chromium-browser &> /dev/null; then
      echo -e "${GREEN}✓${NC} Chrome/Chromium 已安装"
    else
      echo -e "${RED}✗${NC} Chrome/Chromium 未安装"
      echo "   Ubuntu/Debian: sudo apt install google-chrome-stable"
      echo "   Fedora: sudo dnf install google-chrome-stable"
    fi
    ;;
esac

echo ""

# 步骤 2: 安装 Playwright
echo "═══════════════════════════════════════════════════════════"
echo "步骤 2: 安装 Playwright"
echo "═══════════════════════════════════════════════════════════"

if [ ! -f "package.json" ]; then
  echo "📦 创建 package.json..."
  npm init -y
fi

echo "📦 安装 Playwright..."
npm install -D @playwright/test

echo "📦 安装 Playwright 浏览器..."
npx playwright install chromium

# 可选：安装 MCP SDK
echo ""
echo "📦 安装 @playwright/mcp (可选)..."
npm install -D @playwright/mcp || echo "⚠️  @playwright/mcp 安装失败，继续..."

echo ""

# 步骤 3: 安装 Chrome DevTools MCP
echo "═══════════════════════════════════════════════════════════"
echo "步骤 3: 安装 Chrome DevTools MCP"
echo "═══════════════════════════════════════════════════════════"

# 使用 npx 直接运行（推荐方式）
echo "📦 验证 Chrome DevTools MCP (npx)..."
npx -y chrome-devtools-mcp@latest --version && {
  echo -e "${GREEN}✓${NC} Chrome DevTools MCP 可用"
  CHROME_DEVTOOLS_MCP_METHOD="npx"
} || {
  echo -e "${RED}✗${NC} Chrome DevTools MCP 验证失败"
  echo "   请检查网络连接"
  CHROME_DEVTOOLS_MCP_METHOD="manual"
}

echo ""

# 步骤 4: 配置 MCP
echo "═══════════════════════════════════════════════════════════"
echo "步骤 4: 配置 MCP 服务器"
echo "═══════════════════════════════════════════════════════════"

MCP_CONFIG_DIR="$HOME/.claude"
MCP_CONFIG_FILE="${MCP_CONFIG_DIR}/mcp.json"

# 创建备份
if [ -f "$MCP_CONFIG_FILE" ]; then
  echo "📋 备份现有配置..."
  cp "$MCP_CONFIG_FILE" "${MCP_CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
fi

# 创建配置目录
mkdir -p "$MCP_CONFIG_DIR"

# 生成配置
echo "📝 生成 MCP 配置..."

if [ "$CHROME_DEVTOOLS_MCP_METHOD" = "npx" ]; then
  CHROME_DEVTOOLS_COMMAND="npx"
  CHROME_DEVTOOLS_ARGS='["-y", "chrome-devtools-mcp@latest"]'
else
  CHROME_DEVTOOLS_COMMAND="echo"
  CHROME_DEVTOOLS_ARGS='["请手动配置 Chrome DevTools MCP 路径"]'
fi

cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless=false"],
      "env": {
        "PLAYWRIGHT_BROWSERS_PATH": "0"
      }
    },
    "chrome-devtools": {
      "command": "${CHROME_DEVTOOLS_COMMAND}",
      "args": ${CHROME_DEVTOOLS_ARGS},
      "env": {
        "CHROME_REMOTE_URL": "http://localhost:9222"
      },
      "type": "stdio"
    }
  }
}
EOF

echo -e "${GREEN}✓${NC} MCP 配置已保存到：${MCP_CONFIG_FILE}"
echo ""
cat "$MCP_CONFIG_FILE"

echo ""

# 步骤 5: 创建测试示例
echo "═══════════════════════════════════════════════════════════"
echo "步骤 5: 创建测试示例和配置文件"
echo "═══════════════════════════════════════════════════════════"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 创建目录
mkdir -p "${PROJECT_ROOT}/tests/e2e"
mkdir -p "${PROJECT_ROOT}/tests/devtools"
mkdir -p "${PROJECT_ROOT}/scripts"

echo "📝 创建 Playwright 配置文件..."
cat > "${PROJECT_ROOT}/playwright.config.ts" << 'EOCONFIG'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }]
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',
    launchOptions: {
      args: [
        '--remote-debugging-port=9222',
        '--disable-gpu',
        '--disable-dev-shm-usage'
      ]
    }
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'chromium-devtools',
      use: {
        ...devices['Desktop Chrome'],
        launchOptions: {
          args: [
            '--remote-debugging-port=9223',
            '--disable-gpu',
            '--disable-dev-shm-usage'
          ],
          devtools: true
        }
      }
    }
  ]
});
EOCONFIG

echo "📝 创建 Chrome 启动脚本..."
cat > "${PROJECT_ROOT}/scripts/start-chrome.sh" << 'EOCHROME'
#!/bin/bash
PORT=${1:-9222}
PROFILE_DIR="/tmp/chrome-dev-profile-${PORT}"

case "$(uname -s)" in
  Darwin)
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    ;;
  Linux)
    CHROME_PATH="/usr/bin/google-chrome"
    ;;
  *)
    echo "不支持的操作系统"
    exit 1
    ;;
esac

if [ ! -f "$CHROME_PATH" ]; then
  echo "Chrome 未找到"
  exit 1
fi

rm -rf "$PROFILE_DIR"
mkdir -p "$PROFILE_DIR"

"$CHROME_PATH" \
  --remote-debugging-port="${PORT}" \
  --user-data-dir="${PROFILE_DIR}" \
  --no-first-run \
  --no-default-browser-check \
  --disable-gpu \
  --disable-dev-shm-usage &

echo "Chrome 已启动 (PID: $!), 端口：${PORT}"
echo "调试地址：http://localhost:${PORT}/json/version"
EOCHROME

chmod +x "${PROJECT_ROOT}/scripts/start-chrome.sh"

echo -e "${GREEN}✓${NC} 测试示例已创建"

echo ""

# 步骤 6: 验证安装
echo "═══════════════════════════════════════════════════════════"
echo "步骤 6: 验证安装"
echo "═══════════════════════════════════════════════════════════"

echo "🔍 验证 Playwright..."
npx playwright --version

if [ "$CHROME_DEVTOOLS_MCP_METHOD" = "npx" ]; then
  echo "🔍 验证 Chrome DevTools MCP..."
  npx -y chrome-devtools-mcp@latest --version || echo "⚠️  验证失败"
fi

echo ""

# 完成
echo "═══════════════════════════════════════════════════════════"
echo "✅ 安装完成!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📚 下一步:"
echo ""
echo "1. 启动 Chrome (带 DevTools 端口):"
echo "   ${PROJECT_ROOT}/scripts/start-chrome.sh 9222"
echo ""
echo "2. 启动你的应用:"
echo "   npm run dev"
echo ""
echo "3. 运行测试:"
echo "   npx playwright test"
echo ""
echo "4. 查看深度测试示例:"
echo "   ${PROJECT_ROOT}/examples/deep-testing-with-devtools.test.ts"
echo ""
echo "📖 完整文档:"
echo "   ${PROJECT_ROOT}/CHROME_DEVTOOLS_MCP_SETUP.md"
echo ""
