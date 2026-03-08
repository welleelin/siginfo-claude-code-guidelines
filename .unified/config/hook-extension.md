# Hook 系统扩展方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：定义 Hook 系统的扩展策略

---

## 📋 概述

本文档定义如何扩展 oh-my-claudecode 的 31 个 Hook，添加记忆同步、上下文监控和质量门禁 Hook。

---

## 🎯 Hook 来源

### oh-my-claudecode Hook 系统（31 个）

#### 生命周期 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `onSessionStart` | 会话开始 | 初始化环境 |
| `onSessionEnd` | 会话结束 | 清理资源 |
| `onTaskStart` | 任务开始 | 记录任务开始 |
| `onTaskEnd` | 任务完成 | 记录任务完成 |
| `onError` | 错误发生 | 错误处理 |

#### 工具调用 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `preToolUse` | 工具调用前 | 参数验证 |
| `postToolUse` | 工具调用后 | 结果处理 |
| `onToolError` | 工具错误 | 错误恢复 |

#### 上下文管理 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `onContextWarning` | 上下文 70% | 预警通知 |
| `onContextHigh` | 上下文 80% | 准备压缩 |
| `onContextCritical` | 上下文 90% | 强制压缩 |
| `preCompact` | Compact 前 | 保存状态 |
| `postCompact` | Compact 后 | 恢复状态 |

#### 代码操作 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `preWrite` | 写文件前 | 备份文件 |
| `postWrite` | 写文件后 | 格式化代码 |
| `preEdit` | 编辑前 | 验证权限 |
| `postEdit` | 编辑后 | 运行 linter |
| `preDelete` | 删除前 | 确认操作 |
| `postDelete` | 删除后 | 记录日志 |

#### Git 操作 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `preCommit` | 提交前 | 运行测试 |
| `postCommit` | 提交后 | 推送远程 |
| `prePush` | 推送前 | 验证分支 |
| `postPush` | 推送后 | 通知团队 |

#### 其他 Hook

| Hook | 触发时机 | 用途 |
|------|---------|------|
| `onModelSwitch` | 模型切换 | 记录切换 |
| `onCostThreshold` | 成本阈值 | 成本告警 |
| `onTestFail` | 测试失败 | 失败处理 |
| `onBuildFail` | 构建失败 | 构建修复 |
| `onDeployStart` | 部署开始 | 部署准备 |
| `onDeployEnd` | 部署完成 | 部署验证 |

---

## 🔧 新增 Hook

### 1. 记忆同步 Hook

#### onHourlySync

**触发时机**：每小时整点

**用途**：自动执行 Hourly 层同步

**实现**：
```javascript
// .unified/hooks/onHourlySync.js
module.exports = {
  name: 'onHourlySync',
  trigger: 'cron:0 * * * *', // 每小时整点
  async execute(context) {
    const { exec } = context;

    // 执行 Hourly 同步
    await exec('./scripts/sync-hourly.sh');

    // 记录同步时间
    await context.updateState({
      lastHourlySync: new Date().toISOString()
    });

    return { success: true };
  }
};
```

#### onDailyArchive

**触发时机**：每日 23:00

**用途**：自动执行 Daily 层归档

**实现**：
```javascript
// .unified/hooks/onDailyArchive.js
module.exports = {
  name: 'onDailyArchive',
  trigger: 'cron:0 23 * * *', // 每日 23:00
  async execute(context) {
    const { exec } = context;

    // 执行 Daily 归档
    await exec('./scripts/archive-daily.sh');

    // 记录归档时间
    await context.updateState({
      lastDailyArchive: new Date().toISOString()
    });

    return { success: true };
  }
};
```

#### onWeeklySummary

**触发时机**：每周日 22:00

**用途**：自动执行 Weekly 层总结

**实现**：
```javascript
// .unified/hooks/onWeeklySummary.js
module.exports = {
  name: 'onWeeklySummary',
  trigger: 'cron:0 22 * * 0', // 每周日 22:00
  async execute(context) {
    const { exec } = context;

    // 执行 Weekly 总结
    await exec('./scripts/summarize-weekly.sh');

    // 记录总结时间
    await context.updateState({
      lastWeeklySummary: new Date().toISOString()
    });

    return { success: true };
  }
};
```

### 2. 上下文监控 Hook

#### onContextMonitor

**触发时机**：每 30 秒

**用途**：监控上下文使用量

**实现**：
```javascript
// .unified/hooks/onContextMonitor.js
module.exports = {
  name: 'onContextMonitor',
  trigger: 'interval:30000', // 每 30 秒
  async execute(context) {
    const { getContextUsage, notify } = context;

    // 获取上下文使用量
    const usage = await getContextUsage();
    const usagePercent = (usage.used / usage.limit) * 100;

    // 判断阈值
    if (usagePercent >= 90) {
      // 90% - 强制 compact
      await notify({
        level: 'P1',
        title: '上下文使用率达到 90%',
        message: '即将自动执行 compact',
        actions: ['compact']
      });

      // 保存状态
      await context.saveState();

      // 执行 compact
      await context.compact();

    } else if (usagePercent >= 80) {
      // 80% - 自动保存
      await context.saveToMemory();

      await notify({
        level: 'P2',
        title: '上下文使用率达到 80%',
        message: '已自动保存到 Memory'
      });

    } else if (usagePercent >= 70) {
      // 70% - 预警
      await notify({
        level: 'P2',
        title: '上下文使用率达到 70%',
        message: '建议尽快完成当前任务'
      });
    }

    return { usagePercent };
  }
};
```

### 3. 质量门禁 Hook

#### onCodeQualityCheck

**触发时机**：代码写入后

**用途**：自动执行代码质量检查

**实现**：
```javascript
// .unified/hooks/onCodeQualityCheck.js
module.exports = {
  name: 'onCodeQualityCheck',
  trigger: 'postWrite',
  async execute(context) {
    const { file, exec, notify } = context;

    // 只检查代码文件
    if (!file.match(/\.(js|ts|py|go|java)$/)) {
      return { skipped: true };
    }

    // 运行 linter
    const lintResult = await exec(`npx eslint ${file}`);

    if (lintResult.exitCode !== 0) {
      await notify({
        level: 'P2',
        title: '代码质量检查失败',
        message: `文件 ${file} 存在 lint 错误`,
        actions: ['fix', 'ignore']
      });

      return { success: false, errors: lintResult.stderr };
    }

    return { success: true };
  }
};
```

#### onTestCoverageCheck

**触发时机**：测试运行后

**用途**：检查测试覆盖率

**实现**：
```javascript
// .unified/hooks/onTestCoverageCheck.js
module.exports = {
  name: 'onTestCoverageCheck',
  trigger: 'postTest',
  async execute(context) {
    const { testResult, notify } = context;

    // 检查覆盖率
    const coverage = testResult.coverage;

    if (coverage < 80) {
      await notify({
        level: 'P2',
        title: '测试覆盖率不足',
        message: `当前覆盖率 ${coverage}%，要求 ≥ 80%`,
        actions: ['add-tests', 'ignore']
      });

      return { success: false, coverage };
    }

    return { success: true, coverage };
  }
};
```

#### onSecurityCheck

**触发时机**：提交前

**用途**：安全检查

**实现**：
```javascript
// .unified/hooks/onSecurityCheck.js
module.exports = {
  name: 'onSecurityCheck',
  trigger: 'preCommit',
  async execute(context) {
    const { files, exec, notify } = context;

    // 运行安全扫描
    const scanResult = await exec('npm audit');

    if (scanResult.exitCode !== 0) {
      const vulnerabilities = JSON.parse(scanResult.stdout);

      // 检查严重漏洞
      const critical = vulnerabilities.metadata.vulnerabilities.critical;
      const high = vulnerabilities.metadata.vulnerabilities.high;

      if (critical > 0 || high > 0) {
        await notify({
          level: 'P1',
          title: '发现安全漏洞',
          message: `Critical: ${critical}, High: ${high}`,
          actions: ['fix', 'ignore']
        });

        return { success: false, vulnerabilities };
      }
    }

    return { success: true };
  }
};
```

---

## 📐 Hook 配置

### Hook 注册表

创建 `.unified/config/hook-registry.json`：

```json
{
  "version": "1.0.0",
  "hooks": [
    {
      "name": "onHourlySync",
      "source": "sig-guidelines",
      "trigger": "cron:0 * * * *",
      "enabled": true,
      "priority": "P0"
    },
    {
      "name": "onDailyArchive",
      "source": "sig-guidelines",
      "trigger": "cron:0 23 * * *",
      "enabled": true,
      "priority": "P0"
    },
    {
      "name": "onWeeklySummary",
      "source": "sig-guidelines",
      "trigger": "cron:0 22 * * 0",
      "enabled": true,
      "priority": "P0"
    },
    {
      "name": "onContextMonitor",
      "source": "sig-guidelines",
      "trigger": "interval:30000",
      "enabled": true,
      "priority": "P0"
    },
    {
      "name": "onCodeQualityCheck",
      "source": "sig-guidelines",
      "trigger": "postWrite",
      "enabled": true,
      "priority": "P1"
    },
    {
      "name": "onTestCoverageCheck",
      "source": "sig-guidelines",
      "trigger": "postTest",
      "enabled": true,
      "priority": "P1"
    },
    {
      "name": "onSecurityCheck",
      "source": "sig-guidelines",
      "trigger": "preCommit",
      "enabled": true,
      "priority": "P1"
    }
  ]
}
```

### Hook 配置文件

创建 `.unified/config/hooks.yaml`：

```yaml
# Hook 系统配置
hooks:
  # 记忆同步 Hook
  memory:
    hourlySync:
      enabled: true
      schedule: "0 * * * *"
      script: "./scripts/sync-hourly.sh"

    dailyArchive:
      enabled: true
      schedule: "0 23 * * *"
      script: "./scripts/archive-daily.sh"

    weeklySummary:
      enabled: true
      schedule: "0 22 * * 0"
      script: "./scripts/summarize-weekly.sh"

  # 上下文监控 Hook
  context:
    monitor:
      enabled: true
      interval: 30000
      thresholds:
        warning: 70
        high: 80
        critical: 90

  # 质量门禁 Hook
  quality:
    codeQuality:
      enabled: true
      trigger: "postWrite"
      linter: "eslint"

    testCoverage:
      enabled: true
      trigger: "postTest"
      minCoverage: 80

    security:
      enabled: true
      trigger: "preCommit"
      scanner: "npm audit"
```

---

## 🔧 Hook 实现

### Hook 目录结构

```
.unified/hooks/
├── memory/
│   ├── onHourlySync.js
│   ├── onDailyArchive.js
│   └── onWeeklySummary.js
├── context/
│   └── onContextMonitor.js
├── quality/
│   ├── onCodeQualityCheck.js
│   ├── onTestCoverageCheck.js
│   └── onSecurityCheck.js
└── index.js
```

### Hook 加载器

创建 `.unified/hooks/index.js`：

```javascript
// Hook 加载器
const fs = require('fs');
const path = require('path');

class HookManager {
  constructor() {
    this.hooks = new Map();
  }

  // 加载所有 Hook
  loadHooks(hookDir) {
    const categories = fs.readdirSync(hookDir);

    for (const category of categories) {
      const categoryPath = path.join(hookDir, category);

      if (!fs.statSync(categoryPath).isDirectory()) continue;

      const hookFiles = fs.readdirSync(categoryPath)
        .filter(f => f.endsWith('.js'));

      for (const file of hookFiles) {
        const hookPath = path.join(categoryPath, file);
        const hook = require(hookPath);

        this.hooks.set(hook.name, hook);
      }
    }
  }

  // 执行 Hook
  async executeHook(hookName, context) {
    const hook = this.hooks.get(hookName);

    if (!hook) {
      throw new Error(`Hook not found: ${hookName}`);
    }

    return await hook.execute(context);
  }

  // 列出所有 Hook
  listHooks() {
    return Array.from(this.hooks.keys());
  }
}

module.exports = new HookManager();
```

---

## 📝 Hook 使用指南

### 启用/禁用 Hook

```bash
# 启用 Hook
./scripts/hook-manager.sh enable onHourlySync

# 禁用 Hook
./scripts/hook-manager.sh disable onHourlySync

# 列出所有 Hook
./scripts/hook-manager.sh list
```

### 测试 Hook

```bash
# 测试单个 Hook
./scripts/hook-manager.sh test onHourlySync

# 测试所有 Hook
./scripts/hook-manager.sh test-all
```

### 查看 Hook 日志

```bash
# 查看 Hook 执行日志
tail -f logs/hooks.log

# 查看特定 Hook 日志
grep "onHourlySync" logs/hooks.log
```

---

## 🔗 相关文档

- [命令系统合并方案](./command-merge-plan.md) - 命令系统
- [技能库整合方案](./skill-integration.md) - 技能库
- [集成规则](./integration-rules.md) - 规则优先级

---

*版本：1.0.0 | 创建日期：2026-03-08*
