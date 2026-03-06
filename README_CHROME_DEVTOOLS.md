# Chrome DevTools MCP + Playwright 深度测试集成

> 将 Chrome DevTools MCP 与 Playwright 结合，实现更深层次的浏览器自动化测试

---

## 📦 快速开始

### 一键安装

```bash
# 克隆仓库
cd /Users/cloud/Documents/projects/Claude/siginfo-claude-code-guidelines

# 运行安装脚本
./scripts/install-chrome-devtools-mcp.sh
```

### 手动安装

**Step 1: 安装 Playwright**
```bash
npm install -D @playwright/test
npx playwright install chromium
```

**Step 2: 安装 Chrome DevTools MCP**
```bash
# 使用 npx (推荐 - 已发布到 npm)
npx -y chrome-devtools-mcp@latest
```

**Step 3: 配置 MCP**

编辑 `~/.claude/mcp.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless=false"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"],
      "env": {}
    }
  }
}
```

---

## 🚀 使用方法

### 1. 启动 Chrome (带 DevTools 端口)

```bash
./scripts/start-chrome-with-devtools.sh 9222
```

### 2. 运行深度测试

```bash
# 运行所有测试
npx playwright test

# 运行性能测试
npx playwright test tests/devtools/performance.test.ts

# 运行网络监控测试
npx playwright test tests/devtools/network-monitor.test.ts

# 运行覆盖率测试
npx playwright test tests/devtools/coverage.test.ts

# 运行无障碍测试
npx playwright test tests/devtools/accessibility.test.ts
```

---

## 📊 测试能力对比

| 能力 | Playwright | Chrome DevTools MCP | 结合使用 |
|------|-----------|-------------------|---------|
| 页面导航 | ✅ | ❌ | ✅ Playwright |
| 元素交互 | ✅ | ❌ | ✅ Playwright |
| 性能分析 | ⚠️ | ✅ | ✅ 两者结合 |
| 网络监控 | ⚠️ | ✅ | ✅ DevTools 深度监控 |
| 内存分析 | ❌ | ✅ | ✅ DevTools |
| 代码覆盖率 | ⚠️ | ✅ | ✅ DevTools 完整支持 |
| 安全审计 | ❌ | ✅ | ✅ DevTools |
| 无障碍测试 | ⚠️ | ✅ | ✅ DevTools AXTree |

---

## 📁 文件结构

```
siginfo-claude-code-guidelines/
├── CHROME_DEVTOOLS_MCP_SETUP.md       # 完整安装和使用文档
├── scripts/
│   ├── install-chrome-devtools-mcp.sh  # 安装脚本
│   └── start-chrome-with-devtools.sh   # Chrome 启动脚本
├── examples/
│   └── deep-testing-with-devtools.test.ts  # 深度测试示例
└── README_CHROME_DEVTOOLS.md          # 本文件
```

---

## 🧪 测试示例

### 性能分析

```typescript
import { test, expect } from '@playwright/test';

test('页面加载性能', async ({ page, context }) => {
  const client = await context.newCDPSession(page);
  await client.send('Performance.enable');

  await page.goto('/');

  const metrics = await client.send('Performance.getMetrics');
  const fcp = metrics.metrics.find(m => m.name === 'FirstContentfulPaint');

  expect(fcp.value * 1000).toBeLessThan(2500);
});
```

### 内存泄漏检测

```typescript
test('内存泄漏检测', async ({ page, context }) => {
  const client = await context.newCDPSession(page);
  await client.send('Performance.enable');

  // 初始状态
  await page.goto('/');
  const initial = await client.send('Performance.getMetrics');

  // 重复操作
  for (let i = 0; i < 10; i++) {
    await page.click('[data-testid="open-modal"]');
    await page.click('[data-testid="close-modal"]');
  }

  // 最终状态
  const final = await client.send('Performance.getMetrics');

  // 分析增长
  const initialNodes = initial.metrics.find(m => m.name === 'Nodes')?.value;
  const finalNodes = final.metrics.find(m => m.name === 'Nodes')?.value;
  const growth = ((finalNodes - initialNodes) / initialNodes) * 100;

  expect(growth).toBeLessThan(10);
});
```

---

## 🔍 故障排查

### Chrome 无法启动

```bash
# macOS
open -a "Google Chrome" --args --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# 验证端口
curl http://localhost:9222/json/version
```

### MCP 服务连接失败

```bash
# 检查配置
cat ~/.claude/mcp.json

# 重启 Claude Code
claude

# 查看 MCP 日志
# 在 Claude 中询问：/mcp status
```

---

## 📚 相关文档

- [完整安装指南](./CHROME_DEVTOOLS_MCP_SETUP.md)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Playwright 文档](https://playwright.dev/)

---

*版本：1.0.0 | 最后更新：2026-03-05*
