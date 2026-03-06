# Chrome DevTools MCP + Playwright 集成完成总结

> **完成日期**: 2026-03-05
> **版本**: 0.18.1 (Chrome DevTools MCP)

---

## ✅ 已完成内容

### 1. MCP 配置更新

已更新 `~/.claude/mcp.json`：

```json
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
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"],
      "env": {},
      "type": "stdio"
    }
  }
}
```

### 2. 创建的脚本

| 脚本 | 路径 | 用途 |
|------|------|------|
| `install-chrome-devtools-mcp.sh` | `scripts/` | 一键安装脚本 |
| `start-chrome-with-devtools.sh` | `scripts/` | 启动 Chrome（带 DevTools 端口） |
| `start-chrome-devtools-mcp.sh` | `scripts/` | 快速启动指南 |

### 3. 创建的测试示例

| 文件 | 路径 | 内容 |
|------|------|------|
| `deep-testing-with-devtools.test.ts` | `examples/` | 5 大类深度测试示例 |

测试示例包含：
- 📊 **性能分析** - FCP、DCL、内存泄漏检测
- 🌐 **网络监控** - API 调用分析、资源加载分析
- 📈 **代码覆盖率** - JavaScript 覆盖率分析
- ♿ **无障碍测试** - AXTree 完整性、键盘导航
- 🔬 **综合深度测试** - 完整用户流程 + 性能 + 网络 + 覆盖率

### 4. 创建的文档

| 文档 | 路径 |
|------|------|
| `README_CHROME_DEVTOOLS.md` | 快速开始指南 |
| `CHROME_DEVTOOLS_MCP_SETUP.md` | 完整安装和使用文档 |

---

## 🚀 快速开始

### 方式 1: 使用 MCP 自动启动（推荐）

重启 Claude Code，MCP 服务器会自动连接。

### 方式 2: 手动启动 Chrome 后连接

```bash
# 1. 启动 Chrome（带 DevTools 端口）
./scripts/start-chrome-with-devtools.sh 9222

# 2. 在 Claude Code 中，Chrome DevTools MCP 会自动连接到浏览器
```

### 方式 3: 使用 npx 直接运行

```bash
npx -y chrome-devtools-mcp@latest --headless
```

---

## 📊 可用工具（Commands）

### 导航自动化
- `list_pages` - 列出所有页面
- `navigate_page` - 导航到 URL
- `new_page` - 创建新页面
- `select_page` - 选择页面
- `close_page` - 关闭页面
- `wait_for` - 等待元素/文本

### 输入自动化
- `click` - 点击元素
- `fill` - 填写表单
- `fill_form` - 批量填写表单
- `hover` - 悬停
- `press_key` - 按键
- `type_text` - 输入文本

### 调试工具
- `take_screenshot` - 截图
- `take_snapshot` - 获取页面快照
- `evaluate_script` - 执行 JavaScript
- `get_console_message` - 获取控制台消息
- `list_console_messages` - 列出控制台消息
- `lighthouse_audit` - Lighthouse 审计

### 性能工具
- `performance_start_trace` - 开始性能追踪
- `performance_stop_trace` - 停止性能追踪
- `performance_analyze_insight` - 分析性能洞察
- `take_memory_snapshot` - 内存快照

### 网络工具
- `list_network_requests` - 列出网络请求
- `get_network_request` - 获取网络请求详情

### 模拟工具
- `emulate` - 设备模拟
- `resize_page` - 调整页面大小

---

## 🧪 运行测试示例

```bash
# 进入项目目录
cd /Users/cloud/Documents/projects/Claude/siginfo-claude-code-guidelines

# 安装依赖
npm install -D @playwright/test
npx playwright install chromium

# 运行深度测试示例
npx playwright test examples/deep-testing-with-devtools.test.ts
```

---

## 🔧 配置选项

### 有头模式 vs 无头模式

```json
// 有头模式（可以看到浏览器操作）
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest"]
}

// 无头模式（后台运行）
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--headless"]
}

// Slim 模式（仅基本工具）
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--slim", "--headless"]
}
```

### 连接到现有 Chrome 实例

```json
// 通过 HTTP 连接
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--browserUrl", "http://localhost:9222"]
}

// 通过 WebSocket 连接
{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--wsEndpoint", "ws://localhost:9222/devtools/browser/abc123"]
}
```

---

## 🔍 故障排查

### Chrome 未找到

```bash
# macOS - 安装 Chrome
open https://www.google.com/chrome/

# Linux - 安装 Chrome
sudo apt install google-chrome-stable
```

### MCP 连接失败

```bash
# 验证 Chrome DevTools MCP
npx -y chrome-devtools-mcp@latest --version

# 验证 Playwright
npx playwright --version

# 检查 MCP 配置
cat ~/.claude/mcp.json
```

### 端口冲突

```bash
# 检查端口占用
lsof -i :9222

# 使用其他端口
./scripts/start-chrome-with-devtools.sh 9223
```

---

## 📚 参考资源

| 资源 | 链接 |
|------|------|
| Chrome DevTools MCP GitHub | https://github.com/ChromeDevTools/chrome-devtools-mcp |
| Chrome DevTools Protocol | https://chromedevtools.github.io/devtools-protocol/ |
| Playwright 文档 | https://playwright.dev/ |
| MCP Specification | https://modelcontextprotocol.io/ |

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|---------|
| 2026-03-05 | 0.18.1 | 初始版本，完成安装和配置 |

---

*创建时间：2026-03-05*
*最后更新：2026-03-05*
