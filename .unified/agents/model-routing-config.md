# 模型路由配置

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：基于 oh-my-cc 的智能模型路由，实现成本优化

---

## 📋 概述

本文档定义了四项目集成后的统一模型路由策略，基于 oh-my-cc 的智能路由机制，实现：
- 根据任务复杂度自动选择模型
- 成本降低 30-50%
- 保持高质量输出

---

## 🎯 模型能力矩阵

### Claude 模型对比

| 模型 | 上下文 | 编码能力 | 推理能力 | 成本 | 适用场景 |
|------|--------|---------|---------|------|---------|
| **Haiku 4.5** | 200K | ⭐⭐⭐ | ⭐⭐⭐ | $ | 轻量任务、频繁调用 |
| **Sonnet 4.6** | 200K | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | $$$ | 主要开发、复杂编码 |
| **Opus 4.5** | 200K | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | $$$$$ | 架构决策、深度推理 |

### 成本对比

```
Haiku 4.5:  $1  (基准)
Sonnet 4.6: $3  (3x Haiku)
Opus 4.5:   $15 (15x Haiku)
```

---

## 🔀 路由策略

### 1. 按任务类型路由

#### 规划类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| 需求分析 | Opus 4.5 | 需要深度推理和业务理解 |
| 产品规划 | Opus 4.5 | 需要战略思考和全局视野 |
| 架构设计 | Opus 4.5 | 需要深度技术决策 |
| 任务规划（小）| Haiku 4.5 | 简单任务分解 |
| 任务规划（中）| Sonnet 4.6 | 中等复杂度规划 |
| 任务规划（大）| Opus 4.5 | 复杂任务分解 |

#### 开发类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| TDD 开发 | Sonnet 4.6 | 最佳编码能力 |
| 代码生成 | Sonnet 4.6 | 高质量代码生成 |
| 快速开发 | Haiku 4.5 | 简单功能快速实现 |
| 构建修复 | Haiku 4.5 | 简单错误修复 |
| 代码重构 | Sonnet 4.6 | 需要理解代码结构 |

#### 测试类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| 测试计划 | Sonnet 4.6 | 需要全面测试覆盖 |
| E2E 测试 | Haiku 4.5 | 测试脚本生成 |
| 验证循环 | Haiku 4.5 | 简单验证任务 |

#### 审查类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| 代码审查 | Sonnet 4.6 | 需要深度代码理解 |
| 安全审查 | Opus 4.5 | 需要全面安全分析 |
| 质量门禁 | Sonnet 4.6 | 需要质量标准执行 |

#### 记忆类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| 状态保存 | Haiku 4.5 | 简单状态序列化 |
| 记忆同步 | Haiku 4.5 | 简单文件操作 |
| 上下文监控 | Haiku 4.5 | 简单监控任务 |
| 记忆搜索 | Sonnet 4.6 | 需要语义理解 |

#### 专业类任务

| 任务 | 推荐模型 | 原因 |
|------|---------|------|
| UX 设计 | Opus 4.5 | 需要创意和用户理解 |
| 技术文档 | Sonnet 4.6 | 需要技术理解和表达 |
| 文档更新 | Haiku 4.5 | 简单文档修改 |
| 数据库审查 | Sonnet 4.6 | 需要数据库知识 |
| 语言专家 | Sonnet 4.6 | 需要语言深度理解 |

---

### 2. 按复杂度路由

#### 复杂度评估标准

```javascript
function assessComplexity(task) {
  let score = 0;

  // 文件数量
  if (task.files > 10) score += 3;
  else if (task.files > 5) score += 2;
  else if (task.files > 1) score += 1;

  // 代码行数
  if (task.lines > 500) score += 3;
  else if (task.lines > 200) score += 2;
  else if (task.lines > 50) score += 1;

  // 依赖关系
  if (task.dependencies > 5) score += 2;
  else if (task.dependencies > 2) score += 1;

  // 技术栈
  if (task.newTech) score += 2;

  // 架构影响
  if (task.architectureChange) score += 3;

  return score;
}

function selectModel(complexity) {
  if (complexity >= 10) return 'opus-4.5';
  if (complexity >= 5) return 'sonnet-4.6';
  return 'haiku-4.5';
}
```

#### 复杂度分级

| 复杂度 | 分数范围 | 推荐模型 | 示例任务 |
|--------|---------|---------|---------|
| **简单** | 0-4 | Haiku 4.5 | 单文件修改、简单 Bug 修复 |
| **中等** | 5-9 | Sonnet 4.6 | 多文件功能、中型重构 |
| **复杂** | 10+ | Opus 4.5 | 架构设计、大型重构 |

---

### 3. 按 Agent 类型路由

#### Agent 模型映射

```yaml
# .unified/routing/agent-model-mapping.yaml

agents:
  # 规划类 Agent - 使用 Opus
  analyst:
    model: opus-4.5
    reason: "需要深度业务理解"

  pm:
    model: opus-4.5
    reason: "需要产品战略思考"

  architect:
    model: opus-4.5
    reason: "需要架构决策能力"

  scrum-master:
    model: sonnet-4.6
    reason: "需要任务管理能力"

  planner:
    model: sonnet-4.6
    reason: "需要任务分解能力"
    fallback: haiku-4.5  # 简单任务降级

  quick-flow-solo-dev:
    model: haiku-4.5
    reason: "快速开发，成本优先"

  # 开发类 Agent - 使用 Sonnet
  developer:
    model: sonnet-4.6
    reason: "最佳编码能力"

  tdd-guide:
    model: sonnet-4.6
    reason: "需要测试和实现能力"

  build-error-resolver:
    model: haiku-4.5
    reason: "简单错误修复"

  refactor-cleaner:
    model: sonnet-4.6
    reason: "需要代码理解能力"

  # 测试类 Agent - 使用 Haiku/Sonnet
  qa:
    model: sonnet-4.6
    reason: "需要测试计划能力"

  e2e-runner:
    model: haiku-4.5
    reason: "测试脚本生成"

  verification-loop:
    model: haiku-4.5
    reason: "简单验证任务"

  # 审查类 Agent - 使用 Sonnet/Opus
  code-reviewer:
    model: sonnet-4.6
    reason: "需要代码理解能力"
    upgrade: opus-4.5  # 复杂代码升级

  security-reviewer:
    model: opus-4.5
    reason: "需要全面安全分析"

  quality-gate:
    model: sonnet-4.6
    reason: "需要质量标准执行"

  # 记忆类 Agent - 使用 Haiku
  memory-keeper:
    model: haiku-4.5
    reason: "简单状态管理"

  memory-sync:
    model: haiku-4.5
    reason: "简单文件操作"

  context-monitor:
    model: haiku-4.5
    reason: "简单监控任务"

  memory-search:
    model: sonnet-4.6
    reason: "需要语义理解"

  # 专业类 Agent - 使用 Sonnet/Opus
  ux-designer:
    model: opus-4.5
    reason: "需要创意和用户理解"

  tech-writer:
    model: sonnet-4.6
    reason: "需要技术表达能力"

  doc-updater:
    model: haiku-4.5
    reason: "简单文档修改"

  database-reviewer:
    model: sonnet-4.6
    reason: "需要数据库知识"

  language-specialists:
    model: sonnet-4.6
    reason: "需要语言深度理解"
```

---

## 🔧 路由实现

### 路由引擎架构

```
┌─────────────────────────────────────────────────────────────┐
│                    模型路由引擎                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 任务接收                                                │
│         │                                                   │
│         ▼                                                   │
│  2. 任务分析                                                │
│     ├─ 任务类型识别                                         │
│     ├─ 复杂度评估                                           │
│     └─ Agent 类型识别                                       │
│         │                                                   │
│         ▼                                                   │
│  3. 模型选择                                                │
│     ├─ 按任务类型路由                                       │
│     ├─ 按复杂度路由                                         │
│     └─ 按 Agent 类型路由                                    │
│         │                                                   │
│         ▼                                                   │
│  4. 成本评估                                                │
│     ├─ 预估 Token 使用量                                    │
│     ├─ 计算成本                                             │
│     └─ 成本优化建议                                         │
│         │                                                   │
│         ▼                                                   │
│  5. 模型调用                                                │
│     ├─ 调用选定模型                                         │
│     ├─ 监控性能                                             │
│     └─ 记录使用情况                                         │
│         │                                                   │
│         ▼                                                   │
│  6. 结果评估                                                │
│     ├─ 质量评估                                             │
│     ├─ 成本分析                                             │
│     └─ 路由优化                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 路由配置文件

```yaml
# .unified/routing/routing-config.yaml

routing:
  # 默认模型
  default: sonnet-4.6

  # 任务类型路由
  taskTypeRouting:
    enabled: true
    rules:
      planning:
        simple: haiku-4.5
        medium: sonnet-4.6
        complex: opus-4.5
      development:
        simple: haiku-4.5
        medium: sonnet-4.6
        complex: sonnet-4.6
      testing:
        simple: haiku-4.5
        medium: haiku-4.5
        complex: sonnet-4.6
      review:
        simple: sonnet-4.6
        medium: sonnet-4.6
        complex: opus-4.5
      memory:
        simple: haiku-4.5
        medium: haiku-4.5
        complex: sonnet-4.6
      specialized:
        simple: sonnet-4.6
        medium: sonnet-4.6
        complex: opus-4.5

  # 复杂度路由
  complexityRouting:
    enabled: true
    thresholds:
      simple: 4
      medium: 9
    models:
      simple: haiku-4.5
      medium: sonnet-4.6
      complex: opus-4.5

  # Agent 路由
  agentRouting:
    enabled: true
    mappingFile: ./agent-model-mapping.yaml

  # 成本优化
  costOptimization:
    enabled: true
    maxCostPerTask: 0.50  # 美元
    budgetAlert: 0.80     # 80% 预算时预警
    autoDowngrade: true   # 超预算自动降级

  # 性能监控
  monitoring:
    enabled: true
    logFile: .unified/routing/routing-log.json
    metrics:
      - model_usage
      - cost_per_task
      - quality_score
      - response_time
```

---

## 📊 成本优化策略

### 1. 自动降级策略

```javascript
// 自动降级逻辑
function autoDowngrade(task, currentModel, budget) {
  const estimatedCost = estimateTaskCost(task, currentModel);

  if (estimatedCost > budget.remaining) {
    // 尝试降级
    if (currentModel === 'opus-4.5') {
      return 'sonnet-4.6';
    } else if (currentModel === 'sonnet-4.6') {
      return 'haiku-4.5';
    }
  }

  return currentModel;
}
```

### 2. 批量任务优化

```javascript
// 批量任务优化
function optimizeBatchTasks(tasks) {
  // 按复杂度排序
  tasks.sort((a, b) => b.complexity - a.complexity);

  // 复杂任务使用高级模型
  const complexTasks = tasks.filter(t => t.complexity >= 10);
  complexTasks.forEach(t => t.model = 'opus-4.5');

  // 简单任务批量处理
  const simpleTasks = tasks.filter(t => t.complexity < 5);
  simpleTasks.forEach(t => t.model = 'haiku-4.5');

  // 中等任务使用 Sonnet
  const mediumTasks = tasks.filter(t => t.complexity >= 5 && t.complexity < 10);
  mediumTasks.forEach(t => t.model = 'sonnet-4.6');

  return tasks;
}
```

### 3. 缓存策略

```javascript
// 缓存相似任务结果
const cache = new Map();

function getCachedResult(task) {
  const key = generateTaskKey(task);

  if (cache.has(key)) {
    return {
      cached: true,
      result: cache.get(key),
      cost: 0  // 缓存命中无成本
    };
  }

  return null;
}

function cacheResult(task, result) {
  const key = generateTaskKey(task);
  cache.set(key, result);
}
```

---

## 📈 监控与分析

### 使用情况统计

```json
{
  "period": "2026-03-08 to 2026-03-15",
  "modelUsage": {
    "haiku-4.5": {
      "calls": 1250,
      "tokens": 5000000,
      "cost": 50.00,
      "percentage": 45
    },
    "sonnet-4.6": {
      "calls": 800,
      "tokens": 8000000,
      "cost": 240.00,
      "percentage": 40
    },
    "opus-4.5": {
      "calls": 150,
      "tokens": 3000000,
      "cost": 450.00,
      "percentage": 15
    }
  },
  "totalCost": 740.00,
  "costSavings": 370.00,
  "savingsPercentage": 33
}
```

### 质量评估

```json
{
  "qualityMetrics": {
    "haiku-4.5": {
      "successRate": 92,
      "averageQuality": 85,
      "retryRate": 8
    },
    "sonnet-4.6": {
      "successRate": 98,
      "averageQuality": 95,
      "retryRate": 2
    },
    "opus-4.5": {
      "successRate": 99,
      "averageQuality": 98,
      "retryRate": 1
    }
  }
}
```

### 路由优化建议

```markdown
## 路由优化建议

基于过去 7 天的使用数据：

1. **Haiku 使用率偏高**
   - 当前：45%
   - 建议：保持在 40-50%
   - 操作：部分简单任务可继续使用 Haiku

2. **Sonnet 使用率合理**
   - 当前：40%
   - 建议：保持在 35-45%
   - 操作：无需调整

3. **Opus 使用率偏低**
   - 当前：15%
   - 建议：提升到 20-25%
   - 操作：复杂架构决策应使用 Opus

4. **成本节省效果显著**
   - 节省：33%（$370）
   - 目标：30-40%
   - 操作：继续当前策略
```

---

## 🔗 API 接口

### 路由 API

```javascript
// 获取推荐模型
POST /api/routing/recommend
{
  "taskType": "development",
  "complexity": 7,
  "agent": "developer",
  "budget": 0.50
}

// 响应
{
  "success": true,
  "recommendedModel": "sonnet-4.6",
  "estimatedCost": 0.30,
  "reason": "中等复杂度开发任务，Sonnet 最佳",
  "alternatives": [
    {
      "model": "haiku-4.5",
      "cost": 0.10,
      "qualityScore": 85
    },
    {
      "model": "opus-4.5",
      "cost": 1.50,
      "qualityScore": 98
    }
  ]
}
```

### 使用统计 API

```javascript
// 获取使用统计
GET /api/routing/stats?period=7d

// 响应
{
  "success": true,
  "period": "2026-03-08 to 2026-03-15",
  "modelUsage": { ... },
  "costSavings": 370.00,
  "savingsPercentage": 33,
  "qualityMetrics": { ... }
}
```

---

## 🎓 最佳实践

### 1. 任务分类准确性

- 准确识别任务类型
- 正确评估复杂度
- 选择合适的 Agent

### 2. 成本控制

- 设置合理预算
- 启用自动降级
- 监控成本趋势

### 3. 质量保障

- 监控成功率
- 分析重试原因
- 优化路由策略

### 4. 持续优化

- 定期分析使用数据
- 调整路由规则
- 更新模型映射

---

## 📋 实施检查清单

### 配置阶段

- [ ] 创建路由配置文件
- [ ] 配置 Agent 模型映射
- [ ] 设置成本预算
- [ ] 启用监控日志

### 测试阶段

- [ ] 测试简单任务路由
- [ ] 测试中等任务路由
- [ ] 测试复杂任务路由
- [ ] 验证成本计算

### 上线阶段

- [ ] 启用路由引擎
- [ ] 监控使用情况
- [ ] 分析成本节省
- [ ] 优化路由策略

---

## 🔗 相关文档

- [Agent 注册表](./agent-registry.md)
- [Agent 能力增强方案](./agent-capability-enhancement.md)（待创建）
- [命令系统合并方案](../config/command-merge-plan.md)
- [oh-my-cc 智能路由文档](https://github.com/your-org/oh-my-claudecode)

---

*版本：1.0.0*
*创建日期：2026-03-08*
*预期成本节省：30-50%*
