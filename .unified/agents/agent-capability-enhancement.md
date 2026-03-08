# Agent 能力增强方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：为所有 Agent 添加记忆访问、互联网访问和上下文感知能力

---

## 📋 概述

本文档定义了为四项目集成后的 53 个 Agent 统一增强三大核心能力：
1. **记忆访问能力** - 访问长期记忆系统
2. **互联网访问能力** - 通过 Agent-Reach 访问互联网
3. **上下文感知能力** - 实时监控和管理上下文

---

## 🎯 能力增强目标

### 增强前 vs 增强后

| 能力 | 增强前 | 增强后 | 提升 |
|------|--------|--------|------|
| **记忆访问** | 仅部分 Agent 支持 | 所有 Agent 支持 | 100% |
| **互联网访问** | 无 | 所有 Agent 支持 | ∞ |
| **上下文感知** | 被动响应 | 主动监控和管理 | 10x |
| **协作能力** | 独立工作 | 共享记忆和上下文 | 5x |
| **任务恢复** | 无法恢复 | 自动恢复 | ∞ |

---

## 🧠 能力 1：记忆访问能力

### 1.1 记忆系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    三层记忆系统                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Hourly 层（短期记忆）                                       │
│  ├─ 存储：memory/YYYY-MM-DD.md                              │
│  ├─ 频率：每小时同步                                         │
│  ├─ 内容：技术决策、问题解决、用户偏好                        │
│  └─ 保留：7 天                                              │
│                                                             │
│  Daily 层（中期记忆）                                        │
│  ├─ 存储：memory/YYYY-MM-DD.md + MEMORY.md                  │
│  ├─ 频率：每日 23:00 归档                                    │
│  ├─ 内容：项目进展、重要决策、技术债务                        │
│  └─ 保留：永久                                              │
│                                                             │
│  Weekly 层（长期记忆）                                       │
│  ├─ 存储：MEMORY.md                                         │
│  ├─ 频率：每周日 22:00 总结                                  │
│  ├─ 内容：核心知识、最佳实践、架构决策                        │
│  └─ 保留：永久                                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 记忆访问 API

#### 读取记忆

```javascript
// Agent 读取记忆
async function readMemory(agent, query) {
  // 1. 搜索相关记忆
  const results = await memorySearch({
    query: query,
    agent: agent.name,
    layers: ['hourly', 'daily', 'weekly'],
    limit: 10
  });

  // 2. 按相关性排序
  results.sort((a, b) => b.relevance - a.relevance);

  // 3. 返回结果
  return {
    success: true,
    results: results,
    sources: results.map(r => r.source)
  };
}

// 示例：Developer Agent 读取记忆
const memory = await readMemory(developerAgent, "用户登录功能的实现方式");

// 返回：
// {
//   success: true,
//   results: [
//     {
//       content: "用户登录使用 JWT Token 认证",
//       source: "memory/2026-03-05.md",
//       relevance: 0.95,
//       timestamp: "2026-03-05T10:30:00Z"
//     }
//   ]
// }
```

#### 写入记忆

```javascript
// Agent 写入记忆
async function writeMemory(agent, content, layer = 'hourly') {
  const timestamp = new Date().toISOString();
  const memoryEntry = {
    agent: agent.name,
    content: content,
    timestamp: timestamp,
    layer: layer
  };

  // 写入对应层级
  if (layer === 'hourly') {
    await appendToFile(`memory/${getToday()}.md`, formatEntry(memoryEntry));
  } else if (layer === 'daily') {
    await appendToMemoryMd(memoryEntry, 'daily');
  } else if (layer === 'weekly') {
    await appendToMemoryMd(memoryEntry, 'weekly');
  }

  return {
    success: true,
    entryId: generateEntryId(memoryEntry)
  };
}

// 示例：Developer Agent 写入记忆
await writeMemory(developerAgent, {
  decision: "选择 Zustand 作为状态管理方案",
  reason: "轻量、简洁、性能好",
  alternatives: ["Redux Toolkit", "Jotai"],
  impact: "影响所有前端组件"
}, 'daily');
```

#### 搜索记忆

```javascript
// Agent 搜索记忆
async function searchMemory(agent, query, options = {}) {
  const {
    layers = ['hourly', 'daily', 'weekly'],
    timeRange = null,  // { start: Date, end: Date }
    tags = [],
    limit = 10
  } = options;

  // 1. 向量搜索（语义相似度）
  const vectorResults = await vectorSearch(query, {
    layers: layers,
    limit: limit * 2
  });

  // 2. 关键词搜索
  const keywordResults = await keywordSearch(query, {
    layers: layers,
    limit: limit * 2
  });

  // 3. 混合排序（70% 向量 + 30% 关键词）
  const combined = combineResults(vectorResults, keywordResults, {
    vectorWeight: 0.7,
    keywordWeight: 0.3
  });

  // 4. 时间衰减
  if (timeRange) {
    combined.forEach(r => {
      r.score *= calculateTimeDecay(r.timestamp, timeRange);
    });
  }

  // 5. 标签过滤
  if (tags.length > 0) {
    combined = combined.filter(r =>
      tags.some(tag => r.tags.includes(tag))
    );
  }

  // 6. 返回 Top N
  return combined.slice(0, limit);
}

// 示例：Architect Agent 搜索记忆
const results = await searchMemory(architectAgent, "数据库选型", {
  layers: ['daily', 'weekly'],
  timeRange: { start: new Date('2026-03-01'), end: new Date() },
  tags: ['database', 'architecture'],
  limit: 5
});
```

### 1.3 记忆访问权限

#### 权限矩阵

| Agent 类型 | Hourly 读 | Hourly 写 | Daily 读 | Daily 写 | Weekly 读 | Weekly 写 |
|-----------|----------|----------|---------|---------|----------|----------|
| **规划类** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **开发类** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **测试类** | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| **审查类** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **记忆类** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **专业类** | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |

#### 权限配置

```yaml
# .unified/agents/memory-permissions.yaml

permissions:
  # 规划类 Agent - 完全访问
  planning:
    read: [hourly, daily, weekly]
    write: [hourly, daily, weekly]
    agents:
      - analyst
      - pm
      - architect
      - scrum-master
      - planner
      - quick-flow-solo-dev

  # 开发类 Agent - 读写 Hourly/Daily
  development:
    read: [hourly, daily, weekly]
    write: [hourly, daily]
    agents:
      - developer
      - tdd-guide
      - build-error-resolver
      - refactor-cleaner
      - language-specialists

  # 测试类 Agent - 读全部，写 Hourly
  testing:
    read: [hourly, daily, weekly]
    write: [hourly]
    agents:
      - qa
      - e2e-runner
      - verification-loop

  # 审查类 Agent - 读写 Hourly/Daily
  review:
    read: [hourly, daily, weekly]
    write: [hourly, daily]
    agents:
      - code-reviewer
      - security-reviewer
      - quality-gate

  # 记忆类 Agent - 完全访问
  memory:
    read: [hourly, daily, weekly]
    write: [hourly, daily, weekly]
    agents:
      - memory-keeper
      - memory-sync
      - context-monitor
      - memory-search

  # 专业类 Agent - 读全部，写 Hourly
  specialized:
    read: [hourly, daily, weekly]
    write: [hourly]
    agents:
      - ux-designer
      - tech-writer
      - doc-updater
      - database-reviewer
```

---

## 🌐 能力 2：互联网访问能力

### 2.1 Agent-Reach 集成

#### 支持的平台

| 平台 | 功能 | Agent 使用场景 |
|------|------|---------------|
| 🌐 **网页** | 阅读任意网页 | 技术调研、文档查阅 |
| 📺 **YouTube** | 字幕提取 + 视频搜索 | 学习资源、教程分析 |
| 📡 **RSS** | 阅读 RSS/Atom 源 | 技术博客追踪 |
| 📦 **GitHub** | 读公开仓库 + 搜索 | 代码参考、工具选型 |
| 🐦 **Twitter/X** | 搜索推文、浏览时间线 | 技术舆论、社区反馈 |
| 📖 **Reddit** | 读帖子和评论 | 技术讨论、问题解决 |
| 📕 **小红书** | 阅读、搜索 | 产品调研、用户反馈 |
| 🔍 **全网搜索** | AI 语义搜索 | 综合调研 |

#### 互联网访问 API

```javascript
// Agent 访问互联网
async function accessInternet(agent, request) {
  const { platform, action, query, url } = request;

  // 1. 检查 Agent 权限
  if (!hasInternetPermission(agent, platform)) {
    return {
      success: false,
      error: "Agent 无权访问该平台"
    };
  }

  // 2. 调用 Agent-Reach
  let result;
  switch (platform) {
    case 'web':
      result = await jinaReader(url);
      break;
    case 'github':
      result = await githubSearch(query);
      break;
    case 'youtube':
      result = await youtubeSubtitle(url);
      break;
    case 'twitter':
      result = await twitterSearch(query);
      break;
    case 'search':
      result = await exaSearch(query);
      break;
    default:
      return { success: false, error: "不支持的平台" };
  }

  // 3. 记录到 Hourly 层
  await writeMemory(agent, {
    action: "互联网访问",
    platform: platform,
    query: query || url,
    result: result,
    timestamp: new Date().toISOString()
  }, 'hourly');

  return {
    success: true,
    result: result
  };
}

// 示例：Architect Agent 搜索 GitHub
const result = await accessInternet(architectAgent, {
  platform: 'github',
  action: 'search',
  query: 'react state management'
});

// 返回：
// {
//   success: true,
//   result: {
//     repositories: [
//       {
//         name: "pmndrs/zustand",
//         stars: 50000,
//         description: "🐻 Bear necessities for state management in React"
//       }
//     ]
//   }
// }
```

#### 互联网访问权限

```yaml
# .unified/agents/internet-permissions.yaml

permissions:
  # 规划类 Agent - 完全访问
  planning:
    platforms: [web, github, youtube, twitter, reddit, search]
    agents:
      - analyst      # 市场调研
      - pm           # 产品调研
      - architect    # 技术调研
      - planner      # 任务调研

  # 开发类 Agent - 技术平台
  development:
    platforms: [web, github, youtube, search]
    agents:
      - developer
      - tdd-guide
      - refactor-cleaner

  # 测试类 Agent - 技术平台
  testing:
    platforms: [web, github, search]
    agents:
      - qa
      - e2e-runner

  # 审查类 Agent - 技术平台 + 安全
  review:
    platforms: [web, github, search]
    agents:
      - code-reviewer
      - security-reviewer

  # 记忆类 Agent - 无需互联网
  memory:
    platforms: []
    agents:
      - memory-keeper
      - memory-sync

  # 专业类 Agent - 按需访问
  specialized:
    ux-designer:
      platforms: [web, twitter, reddit, xiaohongshu]  # 用户调研
    tech-writer:
      platforms: [web, github, youtube]  # 文档参考
    database-reviewer:
      platforms: [web, github, search]  # 数据库调研
```

### 2.2 互联网访问场景

#### 场景 1：技术调研（Architect Agent）

```javascript
// 1. 搜索 GitHub 相关项目
const githubResults = await accessInternet(architectAgent, {
  platform: 'github',
  action: 'search',
  query: 'react state management stars:>10000'
});

// 2. 搜索技术博客
const webResults = await accessInternet(architectAgent, {
  platform: 'search',
  action: 'search',
  query: 'react state management best practices 2026'
});

// 3. 搜索 Twitter 讨论
const twitterResults = await accessInternet(architectAgent, {
  platform: 'twitter',
  action: 'search',
  query: 'react state management'
});

// 4. 综合分析并写入记忆
await writeMemory(architectAgent, {
  decision: "技术调研：React 状态管理方案",
  findings: {
    github: githubResults,
    web: webResults,
    twitter: twitterResults
  },
  recommendation: "推荐使用 Zustand",
  reason: "轻量、简洁、社区活跃"
}, 'daily');
```

#### 场景 2：问题解决（Developer Agent）

```javascript
// 1. 搜索错误信息
const searchResults = await accessInternet(developerAgent, {
  platform: 'search',
  action: 'search',
  query: 'TypeError: Cannot read property of undefined React'
});

// 2. 查看 GitHub Issue
const issueResults = await accessInternet(developerAgent, {
  platform: 'github',
  action: 'search_issues',
  query: 'TypeError Cannot read property undefined'
});

// 3. 查看 Stack Overflow（通过 web）
const stackOverflow = await accessInternet(developerAgent, {
  platform: 'web',
  action: 'read',
  url: 'https://stackoverflow.com/questions/...'
});

// 4. 记录解决方案
await writeMemory(developerAgent, {
  problem: "TypeError: Cannot read property of undefined",
  solution: "添加可选链操作符 (?.) 或空值合并 (??)",
  source: "Stack Overflow + GitHub Issues",
  timestamp: new Date().toISOString()
}, 'hourly');
```

#### 场景 3：学习资源（TDD-Guide Agent）

```javascript
// 1. 搜索 YouTube 教程
const youtubeResults = await accessInternet(tddGuideAgent, {
  platform: 'youtube',
  action: 'search',
  query: 'TDD React testing library tutorial'
});

// 2. 提取字幕
const subtitle = await accessInternet(tddGuideAgent, {
  platform: 'youtube',
  action: 'subtitle',
  url: youtubeResults[0].url
});

// 3. 总结要点
const summary = summarizeSubtitle(subtitle);

// 4. 写入 Weekly 层（最佳实践）
await writeMemory(tddGuideAgent, {
  topic: "TDD 最佳实践",
  source: "YouTube 教程",
  keyPoints: summary,
  url: youtubeResults[0].url
}, 'weekly');
```

---

## 📊 能力 3：上下文感知能力

### 3.1 上下文监控

#### 监控指标

| 指标 | 说明 | 阈值 |
|------|------|------|
| **使用率** | 当前使用 / 总容量 | 70% 预警 / 80% 保存 / 90% compact |
| **增长率** | 每分钟增长的 Token 数 | > 1000 tokens/min 预警 |
| **剩余容量** | 剩余可用 Token 数 | < 20K 预警 |
| **压缩次数** | 会话中 compact 次数 | > 3 次预警 |

#### 监控 API

```javascript
// Agent 查询上下文状态
async function getContextStatus(agent) {
  const status = await queryContextUsage();

  return {
    model: status.model,
    limit: status.limit,
    used: status.used,
    remaining: status.remaining,
    usagePercent: (status.used / status.limit) * 100,
    growthRate: status.growthRate,
    compactCount: status.compactCount,
    alerts: generateAlerts(status)
  };
}

// 示例：Developer Agent 查询上下文
const context = await getContextStatus(developerAgent);

// 返回：
// {
//   model: "claude-sonnet-4",
//   limit: 200000,
//   used: 140000,
//   remaining: 60000,
//   usagePercent: 70,
//   growthRate: 800,  // tokens/min
//   compactCount: 1,
//   alerts: [
//     {
//       level: "P2",
//       message: "上下文使用率达到 70%"
//     }
//   ]
// }
```

### 3.2 自动保存机制

#### 保存触发条件

```javascript
// 上下文监控 Hook
module.exports = {
  name: 'onContextMonitor',
  trigger: 'interval:30000',  // 每 30 秒
  async execute(context) {
    const usage = await getContextUsage();
    const usagePercent = (usage.used / usage.limit) * 100;

    // 70% - 发送预警
    if (usagePercent >= 70 && usagePercent < 80) {
      await notify({
        level: 'P2',
        title: '上下文使用率达到 70%',
        message: `当前使用：${usage.used} / ${usage.limit} tokens`,
        actions: ['继续', '保存并压缩']
      });
    }

    // 80% - 自动保存到 Memory
    if (usagePercent >= 80 && usagePercent < 90) {
      await autoSaveToMemory(context);
      await notify({
        level: 'P2',
        title: '上下文使用率达到 80%，已自动保存',
        message: '关键信息已保存到 MEMORY.md'
      });
    }

    // 90% - 强制 compact
    if (usagePercent >= 90) {
      await context.saveState();
      await context.compact();
      await notify({
        level: 'P1',
        title: '上下文使用率达到 90%，已自动压缩',
        message: '状态已保存，上下文已压缩'
      });
    }
  }
};

// 自动保存到 Memory
async function autoSaveToMemory(context) {
  const criticalInfo = {
    taskId: context.currentTask.id,
    taskProgress: context.currentTask.progress,
    currentStep: context.currentTask.currentStep,
    keyDecisions: context.decisions,
    testResults: context.testResults,
    filesModified: context.filesModified,
    timestamp: new Date().toISOString()
  };

  await writeMemory(context.agent, criticalInfo, 'daily');
}
```

### 3.3 自动恢复机制

#### 恢复流程

```javascript
// Agent 恢复上下文
async function recoverContext(agent, checkpointId) {
  // 1. 读取检查点
  const checkpoint = await readCheckpoint(checkpointId);

  // 2. 恢复任务状态
  agent.currentTask = checkpoint.task;
  agent.progress = checkpoint.progress;
  agent.variables = checkpoint.variables;

  // 3. 读取相关记忆
  const memory = await searchMemory(agent, checkpoint.task.description, {
    layers: ['hourly', 'daily'],
    timeRange: {
      start: checkpoint.timestamp,
      end: new Date()
    },
    limit: 20
  });

  // 4. 重建上下文
  agent.context = {
    checkpoint: checkpoint,
    memory: memory,
    recoveredAt: new Date().toISOString()
  };

  // 5. 验证恢复成功
  const isValid = await validateRecovery(agent);

  return {
    success: isValid,
    agent: agent,
    recoveredFrom: checkpointId
  };
}

// 示例：Developer Agent 恢复上下文
const recovered = await recoverContext(developerAgent, 'checkpoint-20260308-120000');

// 返回：
// {
//   success: true,
//   agent: { ... },
//   recoveredFrom: 'checkpoint-20260308-120000'
// }
```

---

## 🔧 实施方案

### 阶段 1：记忆访问能力（第 1 周）

#### 任务清单

- [ ] 创建记忆访问 API
- [ ] 配置 Agent 权限
- [ ] 实现读取/写入/搜索功能
- [ ] 测试所有 Agent 的记忆访问

#### 产出文件

```
.unified/agents/
├── memory-api.js           # 记忆访问 API 实现
├── memory-permissions.yaml # 权限配置
└── memory-api-test.js      # 测试文件
```

---

### 阶段 2：互联网访问能力（第 2 周）

#### 任务清单

- [ ] 集成 Agent-Reach
- [ ] 配置平台权限
- [ ] 实现互联网访问 API
- [ ] 测试各平台访问

#### 产出文件

```
.unified/agents/
├── internet-api.js           # 互联网访问 API 实现
├── internet-permissions.yaml # 权限配置
└── internet-api-test.js      # 测试文件
```

---

### 阶段 3：上下文感知能力（第 3 周）

#### 任务清单

- [ ] 实现上下文监控 Hook
- [ ] 实现自动保存机制
- [ ] 实现自动恢复机制
- [ ] 测试上下文管理

#### 产出文件

```
.unified/hooks/context/
├── onContextMonitor.js      # 上下文监控 Hook
├── autoSaveToMemory.js      # 自动保存实现
└── recoverContext.js        # 自动恢复实现
```

---

## 📊 验证标准

### 记忆访问能力验证

- [ ] 所有 Agent 可以读取记忆
- [ ] 权限控制正常工作
- [ ] 搜索功能准确率 > 90%
- [ ] 写入记忆成功率 100%

### 互联网访问能力验证

- [ ] 所有平台访问正常
- [ ] 权限控制正常工作
- [ ] 访问结果准确率 > 95%
- [ ] 记录到记忆成功率 100%

### 上下文感知能力验证

- [ ] 上下文监控实时准确
- [ ] 自动保存触发正常
- [ ] 自动压缩触发正常
- [ ] 自动恢复成功率 > 95%

---

## 🔗 相关文档

- [Agent 注册表](./agent-registry.md)
- [模型路由配置](./model-routing-config.md)
- [长期记忆管理规范](../../guidelines/11-LONG_TERM_MEMORY.md)
- [Agent-Reach 集成指南](../../guidelines/12-AGENT_REACH_INTEGRATION.md)
- [上下文管理配置](../config/context-management-config.md)

---

*版本：1.0.0*
*创建日期：2026-03-08*
*预计实施时间：3 周*
