# 长期运行 Agent 有效模式 - Anthropic 官方指南

> 基于 Anthropic 工程团队官方文章《Effective harnesses for long-running agents》

---

## 📋 文章概述

本文档总结了 Anthropic 官方关于构建长期运行 AI Agent 的最佳实践，帮助 Agent 能够可靠地执行数小时甚至数天的复杂任务。

**核心挑战**：
- Agent 容易在长任务中迷失方向
- 上下文限制导致信息丢失
- 错误累积导致任务失败
- 缺乏有效的进度追踪

**解决方案框架**：
1. 任务分解与规划
2. 状态持久化
3. 检查点与恢复
4. 错误处理与重试
5. 人类介入机制

---

## 🎯 核心原则

### 1. 任务分解 (Task Decomposition)

**问题**：Agent 面对复杂任务时无从下手或试图一次性完成。

**Anthropic 建议**：

```
将大任务分解为独立的、可验证的子任务

❌ 坏例子："构建完整的电子商务网站"
✅ 好例子：
  - 创建产品数据表结构
  - 实现产品列表 API
  - 实现购物车功能
  - 实现结账流程
  - 实现订单管理
```

**分解策略**：
- 每个子任务应该在 10-30 分钟内完成
- 子任务之间有明确的依赖关系
- 每个子任务有明确的完成标准
- 子任务可以独立验证

---

### 2. 状态持久化 (State Persistence)

**问题**：会话中断或上下文超限时，任务进度丢失。

**Anthropic 建议**：

**关键状态保存到文件**：
```json
{
  "taskId": "task-52",
  "taskTitle": "实现用户登录功能",
  "currentPhase": "implementation",
  "completedSteps": [
    {
      "step": "需求分析",
      "completedAt": "2026-03-03T10:00:00Z",
      "output": "需求摘要文档"
    },
    {
      "step": "编写测试",
      "completedAt": "2026-03-03T10:15:00Z",
      "output": "e2e/login.spec.ts"
    }
  ],
  "currentStep": {
    "name": "实现功能",
    "startedAt": "2026-03-03T10:30:00Z",
    "progress": 50,
    "details": "正在编写登录页面组件"
  },
  "keyDecisions": [
    {
      "decision": "使用 JWT Token 认证",
      "reason": "与现有系统兼容",
      "timestamp": "2026-03-03T10:05:00Z"
    }
  ],
  "modifiedFiles": [
    "src/views/login/index.vue",
    "src/api/auth.ts"
  ],
  "testResults": {
    "passed": 0,
    "failed": 2,
    "pending": 3
  }
}
```

**保存频率**：
- 每个步骤完成后立即保存
- 关键决策后立即保存
- 至少每 5 分钟保存一次心跳

---

### 3. 检查点与恢复 (Checkpoints & Recovery)

**问题**：任务中断后无法从断点继续。

**Anthropic 建议**：

**检查点类型**：

| 检查点类型 | 触发条件 | 保存内容 |
|-----------|---------|---------|
| 步骤检查点 | 每个步骤完成 | 步骤输出、测试结果 |
| 阶段检查点 | 每个阶段完成 | 阶段总结、关键决策 |
| 定时检查点 | 每 5 分钟 | 当前状态、进度 |
| 异常检查点 | 遇到错误前 | 错误上下文、堆栈 |

**恢复流程**：
```
1. 检测任务中断
2. 读取最近的检查点
3. 恢复任务状态
4. 从中断点继续执行
5. 验证恢复成功
```

**检查点文件格式**：
```json
{
  "checkpointId": "checkpoint-task-52-20260303-103000",
  "taskId": "task-52",
  "timestamp": "2026-03-03T10:30:00Z",
  "type": "step_completion",
  "state": {
    "phase": "implementation",
    "completedSteps": 2,
    "totalSteps": 6,
    "progress": 33
  },
  "output": {
    "lastStep": "编写测试",
    "outputFiles": ["e2e/login.spec.ts"],
    "testResults": {"passed": 0, "failed": 2}
  },
  "nextStep": {
    "name": "实现功能",
    "estimatedTime": 30
  },
  "recoveryInfo": {
    "canResumeFrom": "编写测试完成",
    "resumeCommand": "continue-task --from step-3"
  }
}
```

---

### 4. 错误处理与重试 (Error Handling & Retry)

**问题**：遇到错误时 Agent 重复尝试相同操作或放弃任务。

**Anthropic 建议**：

**错误分级**：

| 级别 | 类型 | 处理策略 |
|------|------|---------|
| L1 - 轻微 | 网络超时、临时失败 | 自动重试，最多 3 次 |
| L2 - 中等 | API 不可用、资源缺失 | 尝试备选方案，通知人类 |
| L3 - 严重 | 权限错误、数据损坏 | 立即停止，通知人类 |

**重试策略**：
```javascript
const retryConfig = {
  maxRetries: 3,
  initialDelay: 1000,     // 1 秒
  maxDelay: 60000,        // 60 秒
  backoffMultiplier: 2,   // 指数退避

  // 重试条件
  retryableErrors: [
    'NETWORK_TIMEOUT',
    'TEMPORARY_FAILURE',
    'RATE_LIMIT_EXCEEDED'
  ]
}

// 重试逻辑
async function executeWithRetry(operation, config) {
  let lastError
  for (let i = 0; i < config.maxRetries; i++) {
    try {
      return await operation()
    } catch (error) {
      lastError = error
      if (!isRetryable(error)) throw error

      const delay = Math.min(
        config.initialDelay * Math.pow(config.backoffMultiplier, i),
        config.maxDelay
      )
      await sleep(delay)
    }
  }
  throw new Error(`Max retries exceeded: ${lastError.message}`)
}
```

**错误日志格式**：
```json
{
  "errorId": "error-task-52-20260303-104500",
  "taskId": "task-52",
  "timestamp": "2026-03-03T10:45:00Z",
  "step": "实现功能",
  "error": {
    "type": "L2",
    "code": "API_UNAVAILABLE",
    "message": "认证 API 无法访问"
  },
  "context": {
    "attemptedOperation": "POST /api/auth/login",
    "requestBody": { "username": "...", "password": "..." },
    "response": null,
    "networkError": "Connection refused"
  },
  "actions": [
    {
      "action": "retry",
      "attempt": 1,
      "result": "failed",
      "timestamp": "2026-03-03T10:45:30Z"
    },
    {
      "action": "try_alternative",
      "alternative": "使用备用 API 端点",
      "result": "failed",
      "timestamp": "2026-03-03T10:46:00Z"
    },
    {
      "action": "notify_human",
      "level": "P1",
      "channel": "feishu",
      "timestamp": "2026-03-03T10:46:30Z"
    }
  ],
  "resolution": {
    "status": "pending_human_intervention",
    "assignedTo": "user-001",
    "notifiedAt": "2026-03-03T10:46:30Z"
  }
}
```

---

### 5. 人类介入机制 (Human Intervention)

**问题**：Agent 在需要人类决策时继续执行，导致方向错误。

**Anthropic 建议**：

**需要人类介入的场景**：
- 任务规划完成后（确认方向）
- 遇到 L2/L3 错误时（决策如何处理）
- 风险评估后（确认是否接受）
- 架构决策点（选择技术方案）
- 数据删除操作（确认安全）
- 发布/部署决策（业务判断）

**通知格式**：
```
【任务待确认】任务 52 - 需求分析完成

任务：实现用户登录功能
当前阶段：需求分析完成

📋 需求摘要
- 支持账号密码登录
- 支持记住登录状态
- 支持第三方登录（可选）

⚠️ 需要确认
- 是否需要支持手机验证码登录？
- Token 有效期设置为多久？

🔗 操作
[查看详情] [确认继续] [修改需求] [暂停任务]

期望响应时间：2 小时
```

**等待机制**：
```javascript
// 阻塞式等待人类确认
async function waitForHumanConfirmation(taskId, question, options) {
  // 发送通知
  const notifyId = await sendNotification({
    taskId,
    type: 'human_intervention',
    level: 'P2',
    question,
    options
  })

  // 暂停任务
  await pauseTask(taskId)

  // 等待确认（最长等待 2 小时）
  const result = await waitForConfirmation(notifyId, {
    timeout: 7200000,
    pollInterval: 5000
  })

  // 恢复任务
  if (result.action === 'confirm') {
    await resumeTask(taskId)
    return result
  } else if (result.action === 'modify') {
    // 根据修改调整任务
    await adjustTask(taskId, result.modifications)
    return result
  } else {
    // 任务暂停或取消
    await cancelTask(taskId)
    return null
  }
}
```

---

## 📊 完整的任务执行框架

### 框架架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    长期运行 Agent 框架                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────┐     ┌───────────────┐     ┌───────────────┐ │
│  │  任务接收层   │────▶│  任务分解层   │────▶│  执行引擎层   │ │
│  │               │     │               │     │               │ │
│  │ - 接收任务    │     │ - 分解为步骤  │     │ - 执行步骤    │ │
│  │ - 理解目标    │     │ - 定义依赖    │     │ - 监控进度    │ │
│  │ - 选择模式    │     │ - 估算时间    │     │ - 记录日志    │ │
│  └───────────────┘     └───────────────┘     └───────────────┘ │
│                                                   │             │
│                                                   ▼             │
│  ┌───────────────┐     ┌───────────────┐     ┌───────────────┐ │
│  │  恢复层       │◀────│  状态管理层   │◀────│  检查点层     │ │
│  │               │     │               │     │               │ │
│  │ - 检测中断    │     │ - 保存状态    │     │ - 创建检查点  │ │
│  │ - 读取检查点  │     │ - 持久化      │     │ - 记录输出    │ │
│  │ - 恢复执行    │     │ - 加载上下文  │     │ - 验证成功    │ │
│  └───────────────┘     └───────────────┘     └───────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┤ │
│  │                    错误处理层                                │ │
│  │                                                             │ │
│  │  ┌───────────┐    ┌───────────┐    ┌───────────┐          │ │
│  │  │ L1 错误   │    │ L2 错误   │    │ L3 错误   │          │ │
│  │  │ 自动重试  │    │ 备选方案  │    │ 人类介入  │          │ │
│  │  └───────────┘    └───────────┘    └───────────┘          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┤ │
│  │                    人类介入层                                │ │
│  │                                                             │ │
│  │  - 任务规划确认  - 错误处理决策  - 风险评估确认            │ │
│  │  - 架构决策    - 发布决策      - 异常处理                  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 执行引擎详细流程

```
开始执行任务
    │
    ▼
┌─────────────────┐
│ 1. 读取任务配置 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 加载或恢复   │◀──── 从中断恢复
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. 分解任务     │
│    - 识别步骤   │
│    - 建立依赖   │
│    - 估算时间   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. 执行步骤循环 │
│                 │
│ for each step:  │
│   a. 检查上下文 │────▶ 达到阈值 → 触发压缩
│   b. 执行步骤   │
│   c. 验证结果   │────▶ 失败 → 错误处理
│   d. 保存检查点 │
│   e. 更新进度   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. 人类确认点？ │
│                 │
│    是 ──▶ 发送通知
│           等待确认
│           继续执行
│                 │
│    否 ──▶ 继续   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 6. 所有步骤完成？│
│                 │
│    否 ──▶ 继续循环
│                 │
│    是 ──▶ 生成报告
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 7. 任务完成     │
│    - 保存最终状态
│    - 生成报告   │
│    - 通知人类   │
└─────────────────┘
```

---

## 📋 实施清单

### 基础实施（第 1 周）

- [ ] 实现任务分解引擎
- [ ] 实现状态持久化（保存到文件）
- [ ] 实现基本检查点机制
- [ ] 实现简单错误重试
- [ ] 实现基础通知机制

### 中级实施（第 2-3 周）

- [ ] 实现完整的错误分级处理
- [ ] 实现多种检查点类型
- [ ] 实现人类确认工作流
- [ ] 实现进度追踪和报告
- [ ] 实现上下文管理

### 高级实施（第 4 周+）

- [ ] 实现自动恢复机制
- [ ] 实现并行任务执行
- [ ] 实现智能任务规划
- [ ] 实现执行历史分析
- [ ] 实现自动化模式配置

---

## 🎓 案例学习

### 成功案例：3 天完成大型重构

**任务**：重构整个认证系统（预计 3 天）

**实施策略**：
1. 分解为 47 个子任务
2. 每个子任务独立执行和验证
3. 每 5 分钟自动保存状态
4. 每天生成详细进度报告
5. 关键决策点有人类确认

**结果**：
- 实际耗时：2.5 天（提前完成）
- 测试覆盖率：从 60% 提升到 92%
- 无重大返工
- 客户满意度：高

### 失败案例：8 小时任务变成 3 天

**任务**：实现报表导出功能（预计 8 小时）

**失败原因**：
1. 任务没有分解，试图一次性完成
2. 没有保存状态，崩溃后丢失 4 小时工作
3. 没有检查点，无法从断点恢复
4. 遇到错误时重复尝试相同操作
5. 没有通知人类介入，在死胡同里越走越远

**改进措施**：
- 实施任务分解
- 强制状态保存
- 建立检查点机制
- 实现错误分级处理
- 明确人类介入点

---

## 🔗 相关资源

- [系统总则](00-SYSTEM_OVERVIEW.md) - 上下文管理
- [长期运行 Agent 最佳实践](08-LONG_RUNNING_AGENTS.md) - 社区实践
- [项目级自动化模式](09-AUTOMATION_MODES.md) - 自动化配置

---

*版本：1.0.0*
*基于 Anthropic 官方文章《Effective harnesses for long-running agents》*
*最后更新：2026-03-03*
