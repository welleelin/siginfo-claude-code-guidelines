# Chrome DevTools MCP + Playwright 深度测试集成指南

> **版本**: 1.0.0
> **最后更新**: 2026-03-05
> **目标**: 将 Chrome DevTools MCP 与 Playwright 结合用于深度浏览器测试

---

## 📋 概述

### 为什么需要 Chrome DevTools MCP + Playwright？

| 能力 | Playwright | Chrome DevTools MCP | 结合优势 |
|------|-----------|-------------------|---------|
| 页面自动化 | ✅ 完整支持 | ❌ 不支持 | Playwright 负责导航和交互 |
| 性能分析 | ⚠️ 有限 | ✅ 完整 CDP 支持 | DevTools 提供深度性能数据 |
| 网络监控 | ⚠️ 基本 | ✅ 详细 CDP 事件 | DevTools 提供底层网络分析 |
| 内存分析 | ❌ 不支持 | ✅ Heap Snapshot | DevTools 独家能力 |
| 代码覆盖率 | ⚠️ 基本 | ✅ 完整支持 | DevTools 更详细 |
| 安全测试 | ⚠️ 有限 | ✅ 完整审计 | DevTools 提供安全审计 |
| 无障碍测试 | ⚠️ 基本 | ✅ Axiom 集成 | DevTools 完整 a11y 审计 |

### 架构设计

```
┌─────────────────────────────────────────────────────────────────┐
│                    测试执行层                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐         ┌─────────────────┐                │
│  │   Playwright    │         │  Chrome DevTools│                │
│  │      MCP        │         │      MCP        │                │
│  │                 │         │                 │                │
│  │ - 页面导航      │         │ - 性能分析      │                │
│  │ - 元素交互      │         │ - 网络监控      │                │
│  │ - 截图/录像     │         │ - 内存分析      │                │
│  │ - 断言验证      │         │ - 代码覆盖率    │                │
│  │                 │         │ - 安全审计      │                │
│  │                 │         │ - 无障碍测试    │                │
│  └────────┬────────┘         └────────┬────────┘                │
│           │                           │                         │
│           └───────────┬───────────────┘                         │
│                       │                                         │
│                       ▼                                         │
│            ┌─────────────────────┐                              │
│            │   Chrome/Chromium   │                              │
│            │   (DevTools 协议)   │                              │
│            └─────────────────────┘                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 安装步骤

### Step 1: 安装 Chrome DevTools MCP

**方式 A: 使用 uvx (推荐)**

```bash
# 使用 uvx 直接从 GitHub 安装
uvx --from git+https://github.com/ChromeDevTools/chrome-devtools-mcp.git chrome-devtools-mcp

# 或安装到全局
uv pip install git+https://github.com/ChromeDevTools/chrome-devtools-mcp.git
```

**方式 B: 手动克隆安装**

```bash
# 1. 克隆仓库
git clone https://github.com/ChromeDevTools/chrome-devtools-mcp.git
cd chrome-devtools-mcp

# 2. 安装依赖
pip install -e .

# 3. 验证安装
chrome-devtools-mcp --version
```

**方式 C: 使用 Docker (隔离环境)**

```bash
# 拉取镜像
docker pull browsertools/chrome-devtools

# 运行 MCP 服务
docker run -p 9222:9222 browsertools/chrome-devtools
```

### Step 2: 配置 MCP 服务器

编辑 `~/.claude/mcp.json` 或项目级 `.claude/mcp.json`：

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
      "command": "uvx",
      "args": ["--from", "git+https://github.com/ChromeDevTools/chrome-devtools-mcp.git", "chrome-devtools-mcp"],
      "env": {
        "CHROME_REMOTE_URL": "http://localhost:9222"
      },
      "type": "stdio"
    }
  }
}
```

### Step 3: 配置 Chrome 启动参数

创建启动脚本 `scripts/start-chrome-devtools.sh`：

```bash
#!/bin/bash
# scripts/start-chrome-devtools.sh

# 查找 Chrome 应用路径
case "$(uname -s)" in
  Darwin)
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    ;;
  Linux)
    CHROME_PATH="/usr/bin/google-chrome"
    ;;
  MINGW*|CYGWIN*|MSYS*)
    CHROME_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"
    ;;
  *)
    echo "Unsupported OS"
    exit 1
    ;;
esac

# 检查 Chrome 是否存在
if [ ! -f "$CHROME_PATH" ]; then
  echo "Chrome not found at $CHROME_PATH"
  exit 1
fi

# 启动 Chrome 并开启 DevTools 端口
"$CHROME_PATH" \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-dev-profile \
  --no-first-run \
  --no-default-browser-check \
  --disable-gpu \
  --disable-dev-shm-usage

echo "Chrome started with DevTools on port 9222"
```

### Step 4: 安装 Playwright 浏览器

```bash
# 安装 Playwright 浏览器
npx playwright install chromium

# 验证安装
npx playwright --version
```

---

## 🔧 集成配置

### 配置文件布局

```
project/
├── .claude/
│   └── mcp.json                    # MCP 服务器配置
├── tests/
│   ├── e2e/
│   │   ├── example.spec.ts         # 基础 E2E 测试
│   │   └── deep-dive.spec.ts       # 深度测试示例
│   ├── devtools/
│   │   ├── performance.test.ts     # 性能测试
│   │   ├── coverage.test.ts        # 覆盖率测试
│   │   └── accessibility.test.ts   # 无障碍测试
│   └── helpers/
│       └── devtools-integration.ts # 集成辅助函数
├── playwright.config.ts            # Playwright 配置
└── scripts/
    ├── start-chrome-devtools.sh    # Chrome 启动脚本
    └── run-deep-tests.sh           # 深度测试运行脚本
```

### Playwright 配置

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],

  // 共享配置
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',

    // Chrome DevTools 配置
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
```

---

## 🧪 测试示例

### 示例 1: 性能分析测试

```typescript
// tests/devtools/performance.test.ts
import { test, expect } from '@playwright/test';

test.describe('性能分析', () => {
  test('页面加载性能', async ({ page, context }) => {
    // 启用性能监控
    const client = await context.newCDPSession(page);
    await client.send('Performance.enable');

    // 开始导航
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    const loadTime = Date.now() - startTime;

    // 获取性能指标
    const metrics = await client.send('Performance.getMetrics');
    const metricMap = Object.fromEntries(
      metrics.metrics.map(m => [m.name, m.value])
    );

    console.log('性能指标:', metricMap);

    // 断言
    expect(loadTime).toBeLessThan(3000); // 3 秒内加载完成
    expect(metricMap['FirstContentfulPaint'] * 1000).toBeLessThan(1500);
    expect(metricMap['DomContentLoaded'] * 1000).toBeLessThan(2000);
  });

  test('内存泄漏检测', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用 DOM 和性能监控
    await client.send('DOM.enable');
    await client.send('Performance.enable');

    // 初始快照
    await page.goto('/');
    const initialMetrics = await client.send('Performance.getMetrics');

    // 执行操作
    for (let i = 0; i < 10; i++) {
      await page.click('[data-testid="open-modal"]');
      await page.waitForSelector('[data-testid="modal"]');
      await page.click('[data-testid="close-modal"]');
      await page.waitForSelector('[data-testid="modal"]', { state: 'hidden' });
    }

    // 操作后快照
    const finalMetrics = await client.send('Performance.getMetrics');

    // 分析内存增长
    const initialNodes = initialMetrics.metrics
      .find(m => m.name === 'Nodes')?.value || 0;
    const finalNodes = finalMetrics.metrics
      .find(m => m.name === 'Nodes')?.value || 0;

    const growth = ((finalNodes - initialNodes) / initialNodes) * 100;

    console.log(`DOM 节点增长：${growth.toFixed(2)}%`);

    // 内存增长不应超过 10%
    expect(growth).toBeLessThan(10);
  });
});
```

### 示例 2: 网络监控测试

```typescript
// tests/devtools/network-monitor.test.ts
import { test, expect } from '@playwright/test';

test.describe('网络监控', () => {
  test('API 调用分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用网络监控
    await client.send('Network.enable');

    const requests: any[] = [];
    const responses: any[] = [];

    // 监听请求
    client.on('Network.requestWillBeSent', (params) => {
      requests.push({
        url: params.request.url,
        method: params.request.method,
        timestamp: params.timestamp
      });
    });

    // 监听响应
    client.on('Network.responseReceived', (params) => {
      responses.push({
        url: params.response.url,
        status: params.response.status,
        mimeType: params.response.mimeType,
        timing: params.response.timing
      });
    });

    // 执行操作
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // 分析 API 调用
    const apiRequests = requests.filter(r => r.url.includes('/api/'));
    const failedRequests = responses.filter(r => r.status >= 400);

    console.log('API 请求:', apiRequests.length);
    console.log('失败请求:', failedRequests.length);

    // 断言
    expect(failedRequests.length).toBe(0);

    // 检查慢请求
    const slowRequests = responses.filter(r =>
      r.timing?.receiveHeadersEnd > 1000
    );

    if (slowRequests.length > 0) {
      console.warn('慢请求:', slowRequests.map(r => r.url));
    }
  });

  test('资源加载分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);
    await client.send('Network.enable');

    const resources: any[] = [];

    client.on('Network.loadingFinished', (params) => {
      resources.push({
        requestId: params.requestId,
        encodedDataLength: params.encodedDataLength,
        timestamp: params.timestamp
      });
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // 计算总加载大小
    const totalSize = resources.reduce(
      (sum, r) => sum + r.encodedDataLength,
      0
    );

    console.log(`页面总大小：${(totalSize / 1024).toFixed(2)} KB`);

    // 断言页面大小不超过 2MB
    expect(totalSize).toBeLessThan(2 * 1024 * 1024);
  });
});
```

### 示例 3: 代码覆盖率测试

```typescript
// tests/devtools/coverage.test.ts
import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

test.describe('代码覆盖率', () => {
  test('JavaScript 覆盖率分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用覆盖率监控
    await client.send('Profiler.enable');
    await client.send('Profiler.startPreciseCoverage', {
      callCount: true,
      detailed: true
    });

    // 执行测试场景
    await page.goto('/');

    // 导航到各个页面
    await page.click('[data-testid="nav-products"]');
    await page.waitForURL('/products');

    await page.click('[data-testid="nav-about"]');
    await page.waitForURL('/about');

    // 获取覆盖率数据
    const coverage = await client.send('Profiler.takePreciseCoverage');

    // 分析覆盖率
    const stats = {
      totalFunctions: 0,
      coveredFunctions: 0,
      totalRanges: 0,
      coveredRanges: 0
    };

    for (const entry of coverage.result) {
      stats.totalFunctions++;

      const coveredCount = entry.ranges.reduce(
        (sum, r) => sum + (r.count > 0 ? 1 : 0),
        0
      );

      if (coveredCount > 0) {
        stats.coveredFunctions++;
      }

      stats.totalRanges += entry.ranges.length;
      stats.coveredRanges += entry.ranges.filter(r => r.count > 0).length;
    }

    const functionCoverage = (stats.coveredFunctions / stats.totalFunctions) * 100;
    const rangeCoverage = (stats.coveredRanges / stats.totalRanges) * 100;

    console.log('函数覆盖率:', functionCoverage.toFixed(2) + '%');
    console.log('范围覆盖率:', rangeCoverage.toFixed(2) + '%');

    // 保存覆盖率报告
    const reportPath = path.join(process.cwd(), 'coverage', 'coverage.json');
    fs.mkdirSync(path.dirname(reportPath), { recursive: true });
    fs.writeFileSync(reportPath, JSON.stringify(coverage.result, null, 2));

    console.log(`覆盖率报告已保存到：${reportPath}`);
  });
});
```

### 示例 4: 无障碍测试

```typescript
// tests/devtools/accessibility.test.ts
import { test, expect } from '@playwright/test';

test.describe('无障碍测试', () => {
  test('AXTree 完整性检查', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用无障碍监控
    await client.send('Accessibility.enable');

    // 获取完整 AXTree
    const axTree = await client.send('Accessibility.getFullAXTree');

    // 分析 AXTree
    const issues: string[] = [];

    function analyzeNode(node: any, depth: number = 0) {
      const role = node.role?.value;
      const name = node.name?.value;

      // 检查可交互元素是否有名称
      if (['button', 'link', 'input'].includes(role) && !name) {
        issues.push(`[深度${depth}] ${role} 元素缺少可访问名称`);
      }

      // 递归检查子节点
      if (node.children) {
        for (const child of node.children) {
          analyzeNode(child, depth + 1);
        }
      }
    }

    analyzeNode(axTree.nodes[0]);

    if (issues.length > 0) {
      console.warn('无障碍问题:');
      issues.forEach(issue => console.warn('  -', issue));
    }

    // 不应有严重无障碍问题
    expect(issues.length).toBe(0);
  });

  test('键盘导航测试', async ({ page }) => {
    await page.goto('/');

    // 获取所有可聚焦元素
    const focusableSelectors = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      '[tabindex]:not([tabindex="-1"])'
    ].join(', ');

    const focusableElements = await page.$$(focusableSelectors);

    console.log(`可聚焦元素数量：${focusableElements.length}`);

    // 测试 Tab 键导航
    const tabOrder: string[] = [];
    for (let i = 0; i < focusableElements.length; i++) {
      await page.keyboard.press('Tab');
      const focused = await page.evaluate(() => document.activeElement);
      tabOrder.push(focused?.tagName?.toLowerCase() || 'unknown');
    }

    console.log('Tab 键顺序:', tabOrder);

    // 验证焦点没有丢失
    const finalFocused = await page.evaluate(() =>
      document.activeElement === document.body
    );
    expect(finalFocused).toBe(false);
  });
});
```

### 示例 5: 综合深度测试

```typescript
// tests/e2e/deep-dive.spec.ts
import { test, expect } from '@playwright/test';
import * as fs from 'fs';

test.describe('深度集成测试', () => {
  test('完整用户流程 + 性能 + 覆盖率', async ({ page, context }) => {
    // === 1. 设置 CDP 会话 ===
    const client = await context.newCDPSession(page);

    // 启用性能监控
    await client.send('Performance.enable');

    // 启用网络监控
    await client.send('Network.enable');

    // 启用覆盖率监控
    await client.send('Profiler.enable');
    await client.send('Profiler.startPreciseCoverage', {
      callCount: true,
      detailed: true
    });

    // === 2. 收集数据 ===
    const networkRequests: any[] = [];
    const performanceMetrics: any[] = [];

    client.on('Network.requestWillBeSent', (params) => {
      networkRequests.push({
        url: params.request.url,
        method: params.request.method,
        timestamp: params.timestamp
      });
    });

    // === 3. 执行用户流程 ===
    const flowStart = Date.now();

    // 步骤 1: 访问首页
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    performanceMetrics.push({
      step: '首页加载',
      time: Date.now() - flowStart,
      metrics: await client.send('Performance.getMetrics')
    });

    // 步骤 2: 登录
    await page.click('[data-testid="login-button"]');
    await page.fill('[data-testid="username"]', 'testuser');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="submit-login"]');
    await page.waitForURL('/dashboard');

    performanceMetrics.push({
      step: '登录完成',
      time: Date.now() - flowStart,
      metrics: await client.send('Performance.getMetrics')
    });

    // 步骤 3: 访问关键页面
    await page.click('[data-testid="nav-products"]');
    await page.waitForURL('/products');
    await page.waitForSelector('[data-testid="product-list"]');

    performanceMetrics.push({
      step: '产品列表',
      time: Date.now() - flowStart,
      metrics: await client.send('Performance.getMetrics')
    });

    // === 4. 获取最终数据 ===
    const flowEnd = Date.now() - flowStart;

    const finalMetrics = await client.send('Performance.getMetrics');
    const coverage = await client.send('Profiler.takePreciseCoverage');

    // === 5. 生成报告 ===
    const report = {
      timestamp: new Date().toISOString(),
      flowDuration: flowEnd,
      performanceMetrics,
      networkRequests: networkRequests.length,
      coverage: {
        totalFunctions: coverage.result.length,
        // 简化计算
      },
      issues: []
    };

    // 保存报告
    const reportPath = 'test-results/deep-dive-report.json';
    fs.mkdirSync('test-results', { recursive: true });
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

    console.log(`深度测试报告：${reportPath}`);

    // === 6. 断言 ===
    expect(flowEnd).toBeLessThan(30000); // 30 秒内完成整个流程
    expect(networkRequests.filter(r => r.url.includes('/api/')).length).toBeGreaterThan(0);
  });
});
```

---

## 🚀 运行测试

### 创建运行脚本

```bash
#!/bin/bash
# scripts/run-deep-tests.sh

set -e

echo "🚀 启动 Chrome DevTools + Playwright 深度测试"

# Step 1: 启动 Chrome (带 DevTools)
echo "📦 启动 Chrome..."
./scripts/start-chrome-devtools.sh &
CHROME_PID=$!
sleep 2

# Step 2: 等待应用启动
echo "⏳ 等待应用启动..."
wait-on http://localhost:3000 || true

# Step 3: 运行深度测试
echo "🧪 运行深度测试..."
npx playwright test tests/devtools --reporter=html,json

# Step 4: 生成覆盖率报告
echo "📊 生成覆盖率报告..."
npx playwright show-report

# Step 5: 清理
echo "🧹 清理..."
kill $CHROME_PID || true

echo "✅ 测试完成!"
```

### 添加 npm scripts

```json
{
  "scripts": {
    "test:deep": "./scripts/run-deep-tests.sh",
    "test:perf": "npx playwright test tests/devtools/performance.test.ts",
    "test:coverage": "npx playwright test tests/devtools/coverage.test.ts",
    "test:a11y": "npx playwright test tests/devtools/accessibility.test.ts",
    "test:network": "npx playwright test tests/devtools/network-monitor.test.ts"
  }
}
```

---

## 📊 报告与可视化

### 性能报告 HTML 模板

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>深度测试报告</title>
  <style>
    body { font-family: system-ui; max-width: 1200px; margin: 0 auto; padding: 20px; }
    .metric-card { background: #f5f5f5; padding: 16px; border-radius: 8px; margin: 8px 0; }
    .metric-value { font-size: 24px; font-weight: bold; color: #1a73e8; }
    .issue { background: #ffebee; padding: 8px; border-radius: 4px; margin: 4px 0; }
    .success { background: #e8f5e9; }
  </style>
</head>
<body>
  <h1>深度测试报告</h1>
  <div id="report"></div>
  <script>
    fetch('deep-dive-report.json')
      .then(r => r.json())
      .then(data => {
        document.getElementById('report').innerHTML = `
          <div class="metric-card">
            <div>流程耗时</div>
            <div class="metric-value">${data.flowDuration}ms</div>
          </div>
          <div class="metric-card">
            <div>网络请求数</div>
            <div class="metric-value">${data.networkRequests}</div>
          </div>
        `;
      });
  </script>
</body>
</html>
```

---

## 🔍 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| CDP 连接失败 | Chrome 未启动 DevTools | 确保使用 `--remote-debugging-port` 启动 |
| 端口冲突 | 端口被占用 | 更换端口号 (9222 → 9223) |
| MCP 服务找不到 | 路径配置错误 | 检查 `~/.claude/mcp.json` 中的 command |
| 覆盖率为 0 | 未正确启用 | 确保在导航前调用 `enable` |

### 诊断命令

```bash
# 检查 Chrome 是否运行
ps aux | grep Chrome

# 检查 DevTools 端口
lsof -i :9222

# 测试 CDP 连接
curl http://localhost:9222/json/version

# 列出所有调试目标
curl http://localhost:9222/json/list
```

---

## 📚 相关文档

- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Playwright Documentation](https://playwright.dev/)
- [MCP Specification](https://modelcontextprotocol.io/)

---

*版本：1.0.0*
*最后更新：2026-03-05*
