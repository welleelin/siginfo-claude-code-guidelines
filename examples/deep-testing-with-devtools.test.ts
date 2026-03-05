/**
 * Chrome DevTools + Playwright 深度测试示例
 *
 * 这些示例展示了如何结合使用 Playwright 和 Chrome DevTools Protocol
 * 进行更深层次的浏览器测试
 */

import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// 示例 1: 性能分析测试
// ============================================================================

test.describe('📊 性能分析', () => {
  test('页面加载性能指标', async ({ page, context }) => {
    // 创建 CDP 会话
    const client = await context.newCDPSession(page);

    // 启用性能监控
    await client.send('Performance.enable');

    // 开始导航前记录时间
    const startTime = Date.now();

    // 导航到目标页面
    await page.goto('https://example.com');
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;

    // 获取性能指标
    const metrics = await client.send('Performance.getMetrics');
    const metricMap = Object.fromEntries(
      metrics.metrics.map(m => [m.name, m.value])
    );

    console.log('📈 性能指标:', {
      加载时间：`${loadTime}ms`,
      FCP: `${(metricMap['FirstContentfulPaint'] * 1000).toFixed(0)}ms`,
      DCL: `${(metricMap['DomContentLoaded'] * 1000).toFixed(0)}ms`,
      Load: `${(metricMap['Load'] * 1000).toFixed(0)}ms`
    });

    // 性能断言
    expect(loadTime).toBeLessThan(5000);
    expect(metricMap['FirstContentfulPaint'] * 1000).toBeLessThan(2500);
  });

  test('内存泄漏检测', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用 DOM 监控
    await client.send('DOM.enable');
    await client.send('Performance.enable');

    // 初始状态
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const initialMetrics = await client.send('Performance.getMetrics');
    const initialNodes = initialMetrics.metrics
      .find(m => m.name === 'Nodes')?.value || 0;

    console.log(`📍 初始 DOM 节点数：${initialNodes}`);

    // 重复打开关闭模态框 10 次
    for (let i = 0; i < 10; i++) {
      await page.click('[data-testid="open-modal"]');
      await page.waitForSelector('[data-testid="modal"]');
      await page.waitForTimeout(100);
      await page.click('[data-testid="close-modal"]');
      await page.waitForSelector('[data-testid="modal"]', { state: 'hidden' });
    }

    // 强制垃圾回收（如果支持）
    try {
      await client.send('HeapProfiler.collectGarbage');
    } catch (e) {
      console.log('HeapProfiler 不可用，跳过 GC');
    }

    await page.waitForTimeout(500);

    // 最终状态
    const finalMetrics = await client.send('Performance.getMetrics');
    const finalNodes = finalMetrics.metrics
      .find(m => m.name === 'Nodes')?.value || 0;

    const growth = ((finalNodes - initialNodes) / initialNodes) * 100;

    console.log(`📍 最终 DOM 节点数：${finalNodes}`);
    console.log(`📍 节点增长率：${growth.toFixed(2)}%`);

    // 内存泄漏断言：增长不应超过 10%
    expect(growth).toBeLessThan(10);
  });
});

// ============================================================================
// 示例 2: 网络监控测试
// ============================================================================

test.describe('🌐 网络监控', () => {
  test('API 调用分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用网络监控
    await client.send('Network.enable');

    const requests: Array<{
      url: string;
      method: string;
      timestamp: number;
    }> = [];

    const responses: Array<{
      url: string;
      status: number;
      mimeType: string;
      timing?: object;
    }> = [];

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

    // 执行测试场景
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // 分析结果
    const apiRequests = requests.filter(r => r.url.includes('/api/'));
    const failedRequests = responses.filter(r => r.status >= 400);

    console.log(`📡 API 请求数：${apiRequests.length}`);
    console.log(`📡 失败请求数：${failedRequests.length}`);

    // 断言
    expect(failedRequests.length).toBe(0);

    // 检查慢请求
    const slowRequests = responses.filter((r) => {
      const receiveTime = r.timing?.receiveHeadersEnd || 0;
      return receiveTime > 1000;
    });

    if (slowRequests.length > 0) {
      console.warn('⚠️ 慢请求:');
      slowRequests.forEach(r => console.warn(`  - ${r.url}`));
    }
  });

  test('资源加载分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);
    await client.send('Network.enable');

    const resources: Array<{
      requestId: string;
      encodedDataLength: number;
      url: string;
    }> = [];

    client.on('Network.loadingFinished', (params) => {
      resources.push({
        requestId: params.requestId,
        encodedDataLength: params.encodedDataLength,
        url: '' // URL 需要从其他事件获取
      });
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // 计算总大小
    const totalSize = resources.reduce(
      (sum, r) => sum + r.encodedDataLength,
      0
    );

    console.log(`📦 页面总大小：${(totalSize / 1024).toFixed(2)} KB`);
    console.log(`📦 资源数量：${resources.length}`);

    // 断言
    expect(totalSize).toBeLessThan(5 * 1024 * 1024); // 5MB
  });
});

// ============================================================================
// 示例 3: 代码覆盖率测试
// ============================================================================

test.describe('📈 代码覆盖率', () => {
  test('JavaScript 覆盖率分析', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用覆盖率监控
    await client.send('Profiler.enable');
    await client.send('Profiler.startPreciseCoverage', {
      callCount: true,
      detailed: true
    });

    // 执行测试场景 - 访问多个页面
    await page.goto('/');
    await page.click('[data-testid="nav-products"]');
    await page.waitForURL('/products');
    await page.click('[data-testid="nav-about"]');
    await page.waitForURL('/about');

    // 获取覆盖率数据
    const coverage = await client.send('Profiler.takePreciseCoverage');

    // 分析覆盖率
    let totalFunctions = 0;
    let coveredFunctions = 0;
    let totalRanges = 0;
    let coveredRanges = 0;

    for (const entry of coverage.result) {
      totalFunctions++;

      const coveredCount = entry.ranges.reduce(
        (sum, r) => sum + (r.count > 0 ? 1 : 0),
        0
      );

      if (coveredCount > 0) {
        coveredFunctions++;
      }

      totalRanges += entry.ranges.length;
      coveredRanges += entry.ranges.filter(r => r.count > 0).length;
    }

    const functionCoverage = totalFunctions > 0
      ? (coveredFunctions / totalFunctions) * 100
      : 0;
    const rangeCoverage = totalRanges > 0
      ? (coveredRanges / totalRanges) * 100
      : 0;

    console.log(`📊 函数覆盖率：${functionCoverage.toFixed(2)}%`);
    console.log(`📊 范围覆盖率：${rangeCoverage.toFixed(2)}%`);

    // 保存覆盖率报告
    const reportPath = path.join(process.cwd(), 'coverage', 'js-coverage.json');
    fs.mkdirSync(path.dirname(reportPath), { recursive: true });
    fs.writeFileSync(reportPath, JSON.stringify(coverage.result, null, 2));

    console.log(`💾 覆盖率报告已保存到：${reportPath}`);
  });
});

// ============================================================================
// 示例 4: 无障碍测试
// ============================================================================

test.describe('♿ 无障碍测试', () => {
  test('AXTree 完整性检查', async ({ page, context }) => {
    const client = await context.newCDPSession(page);

    // 启用无障碍监控
    await client.send('Accessibility.enable');

    // 获取完整 AXTree
    const axTree = await client.send('Accessibility.getFullAXTree');

    const issues: string[] = [];

    // 分析 AXTree
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
      console.warn('⚠️ 无障碍问题:');
      issues.forEach(issue => console.warn(`  - ${issue}`));
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

    console.log(`⌨️  可聚焦元素数量：${focusableElements.length}`);

    // 测试 Tab 键导航
    for (let i = 0; i < focusableElements.length && i < 20; i++) {
      await page.keyboard.press('Tab');
      const focused = await page.evaluate(() => document.activeElement);
      console.log(`  Tab ${i + 1}: ${focused?.tagName?.toLowerCase()}`);
    }

    // 验证焦点没有丢失
    const isFocusOnBody = await page.evaluate(() =>
      document.activeElement === document.body
    );
    expect(isFocusOnBody).toBe(false);
  });
});

// ============================================================================
// 示例 5: 综合深度测试 - 完整用户流程
// ============================================================================

test.describe('🔬 综合深度测试', () => {
  test('登录流程 - 性能 + 网络 + 覆盖率', async ({ page, context }) => {
    // 创建 CDP 会话
    const client = await context.newCDPSession(page);

    // 启用所有监控
    await client.send('Performance.enable');
    await client.send('Network.enable');
    await client.send('Profiler.enable');
    await client.send('Profiler.startPreciseCoverage', {
      callCount: true,
      detailed: true
    });

    // 数据收集
    const networkRequests: any[] = [];
    const performanceMetrics: any[] = [];

    client.on('Network.requestWillBeSent', (params) => {
      networkRequests.push({
        url: params.request.url,
        method: params.request.method,
        timestamp: params.timestamp
      });
    });

    // 开始执行流程
    const flowStart = Date.now();

    // 步骤 1: 访问首页
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    performanceMetrics.push({
      step: '首页加载',
      time: Date.now() - flowStart,
      metrics: await client.send('Performance.getMetrics')
    });

    // 步骤 2: 点击登录
    await page.click('[data-testid="login-button"]');
    await page.waitForSelector('[data-testid="login-form"]');

    // 步骤 3: 填写表单
    await page.fill('[data-testid="username"]', 'testuser');
    await page.fill('[data-testid="password"]', 'password123');

    // 步骤 4: 提交登录
    await page.click('[data-testid="submit-login"]');
    await page.waitForURL('/dashboard');
    await page.waitForSelector('[data-testid="welcome-message"]');

    performanceMetrics.push({
      step: '登录完成',
      time: Date.now() - flowStart,
      metrics: await client.send('Performance.getMetrics')
    });

    // 获取最终数据
    const flowDuration = Date.now() - flowStart;
    const finalMetrics = await client.send('Performance.getMetrics');
    const coverage = await client.send('Profiler.takePreciseCoverage');

    // 生成报告
    const report = {
      timestamp: new Date().toISOString(),
      flowDuration,
      performanceMetrics,
      networkRequests: {
        total: networkRequests.length,
        api: networkRequests.filter(r => r.url.includes('/api/')).length
      },
      coverage: {
        totalScripts: coverage.result.length
      }
    };

    // 保存报告
    const reportPath = 'test-results/deep-dive-login.json';
    fs.mkdirSync('test-results', { recursive: true });
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

    console.log(`💾 测试报告已保存到：${reportPath}`);

    // 断言
    expect(flowDuration).toBeLessThan(30000);
    expect(networkRequests.filter(r => r.url.includes('/api/login')).length).toBeGreaterThan(0);
  });
});
