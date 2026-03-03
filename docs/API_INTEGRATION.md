# sig-claude-code-guidelines 与 Claude Monitor UI 接口规范

> 本文档定义了两个项目之间的 API 接口和集成方式

---

## 📋 概述

### 项目分工

| 项目 | 职责 |
|------|------|
| **sig-claude-code-guidelines** | 定义行动准则、开发规范、模板脚本 |
| **claude-monitor-ui** | 任务监督、通知发送、确认反馈处理 |

### 集成架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    开发会话流程                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐         ┌─────────────────────────┐  │
│  │  sig-claude-code-    │         │   claude-monitor-ui     │  │
│  │  guidelines          │         │                         │  │
│  │                      │         │  ┌───────────────────┐  │  │
│  │  行动准则执行        │────────▶│  │   PM Agent        │  │  │
│  │  - TDD 流程           │  API    │  │   任务监督        │  │  │
│  │  - 任务规划          │  调用   │  │                   │  │  │
│  │  - 代码审查          │         │  └───────────────────┘  │  │
│  │                      │         │           │              │  │
│  │                      │         │  ┌───────────────────┐  │  │
│  │                      │         │  │  通知中心         │  │  │
│  │                      │         │  │  - 多渠道通知     │  │  │
│  │                      │◀────────│  │  - 确认反馈       │  │  │
│  │                      │  回调   │  │  - 凭证生成       │  │  │
│  └──────────────────────┘         │  └───────────────────┘  │  │
│                                   └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔌 API 接口定义

### 基础信息

```
Base URL: http://localhost:8083/api
Content-Type: application/json
```

---

### 1. 发送通知

**场景**：当任务需要人类确认时（如规划完成、测试失败、阻塞处理）

**端点**：`POST /notification/send`

**请求体**：
```json
{
  "level": "P2",
  "type": "plan_confirm",
  "taskId": "task-52",
  "windowId": "win-001",
  "title": "任务规划待确认",
  "content": "规划已完成，请确认是否继续",
  "details": {
    "planSummary": "实现用户登录功能，包含 3 个阶段",
    "estimatedTime": "2-3 小时",
    "risks": ["需要确认 OAuth 配置"]
  },
  "channels": ["feishu", "in-app"],
  "timeout": 7200000,
  "actions": [
    {
      "label": "✅ 确认执行",
      "value": "confirm",
      "type": "primary"
    },
    {
      "label": "✏️ 修改计划",
      "value": "modify",
      "type": "default"
    },
    {
      "label": "⏸️ 暂停任务",
      "value": "pause",
      "type": "danger"
    }
  ]
}
```

**响应体**：
```json
{
  "success": true,
  "notifyId": "notify-20260303-001",
  "message": "通知已发送",
  "sentChannels": ["feishu", "in-app"],
  "timeoutAt": "2026-03-03T14:30:00Z"
}
```

---

### 2. 确认反馈处理

**场景**：用户通过通知渠道（飞书/钉钉等）点击确认按钮后

**端点**：`POST /notification/confirm`

**请求体**：
```json
{
  "notifyId": "notify-20260303-001",
  "taskId": "task-52",
  "userId": "user-001",
  "action": "confirm",
  "actionData": {
    "modifyReason": ""  // 如果 action=modify，填写修改意见
  },
  "channel": "feishu",
  "timestamp": "2026-03-03T10:30:00Z",
  "signature": "abc123xyz"
}
```

**响应体**：
```json
{
  "success": true,
  "message": "确认已记录",
  "nextStep": "continue_task",
  "凭证已使用": false
}
```

---

### 3. 任务状态更新

**场景**：更新任务的当前状态（开始执行、阻塞、完成等）

**端点**：`POST /task/status`

**请求体**：
```json
{
  "taskId": "task-52",
  "windowId": "win-001",
  "status": "in_progress",
  "notifyLevel": "P2",
  "details": {
    "phase": "implementation",
    "progress": 50,
    "currentStep": "编写登录页面组件"
  }
}
```

**响应体**：
```json
{
  "success": true,
  "message": "状态已更新",
  "task": {
    "id": "task-52",
    "title": "实现用户登录功能",
    "status": "in_progress",
    "startedAt": "2026-03-03T10:00:00Z"
  }
}
```

---

### 4. 获取待执行任务

**场景**：PM Agent 巡检时获取有待执行的任务

**端点**：`GET /tasks?status=pending&autoExecutable=true`

**响应体**：
```json
{
  "success": true,
  "tasks": [
    {
      "id": "task-55",
      "title": "修复登录按钮样式",
      "priority": "P2",
      "autoExecutable": true,
      "estimatedTime": "30 分钟"
    },
    {
      "id": "task-56",
      "title": "优化首页加载性能",
      "priority": "P2",
      "autoExecutable": false,
      "reason": "需要确认性能指标目标"
    }
  ]
}
```

---

### 5. 获取窗口状态

**场景**：PM Agent 巡检时获取所有窗口/会话状态

**端点**：`GET /windows`

**响应体**：
```json
{
  "success": true,
  "windows": [
    {
      "id": "win-001",
      "sessionId": "session-001",
      "taskId": "task-52",
      "status": "in_progress",
      "lastActivity": "2026-03-03T10:25:00Z",
      "idleTime": 300
    },
    {
      "id": "win-002",
      "sessionId": "session-002",
      "taskId": "task-53",
      "status": "waiting_human",
      "lastActivity": "2026-03-03T10:00:00Z",
      "idleTime": 1800,
      "notifyLevel": "P2"
    },
    {
      "id": "win-003",
      "sessionId": "session-003",
      "taskId": null,
      "status": "idle",
      "lastActivity": "2026-03-03T08:00:00Z",
      "idleTime": 7200
    }
  ]
}
```

---

### 6. 发送完成通知

**场景**：任务完成后发送通知

**端点**：`POST /notification/send`

**请求体**：
```json
{
  "level": "P3",
  "type": "task_completed",
  "taskId": "task-52",
  "windowId": "win-001",
  "title": "任务完成",
  "content": "任务已完成，测试通过率 100%",
  "details": {
    "testResults": {
      "passed": 5,
      "failed": 0,
      "total": 5
    },
    "buildStatus": "success",
    "commitHash": "abc1234"
  },
  "channels": ["in-app"]
}
```

---

### 7. 升级通知

**场景**：用户超时未确认，升级通知级别

**端点**：`POST /notification/escalate`

**请求体**：
```json
{
  "notifyId": "notify-20260303-001",
  "taskId": "task-52",
  "fromLevel": "P2",
  "toLevel": "P1",
  "reason": "用户 2 小时未确认",
  "addChannels": ["email"],
  "message": "【升级通知】任务规划待确认 - 已等待 2 小时，请尽快处理"
}
```

**响应体**：
```json
{
  "success": true,
  "message": "通知已升级",
  "sentChannels": ["feishu", "in-app", "email"]
}
```

---

### 8. 获取通知历史

**场景**：查看任务的通知历史

**端点**：`GET /notification/history?taskId=task-52`

**响应体**：
```json
{
  "success": true,
  "notifications": [
    {
      "id": "notify-20260303-001",
      "level": "P2",
      "type": "plan_confirm",
      "sentAt": "2026-03-03T08:30:00Z",
      "channels": ["feishu", "in-app"],
      "status": "confirmed",
      "confirmedAt": "2026-03-03T09:00:00Z",
      "confirmedBy": "user-001"
    }
  ]
}
```

---

## 📋 行动准则中的集成点

### 在 `/plan` 命令执行后

```javascript
// 伪代码示例
async function executePlan(taskDescription) {
  // 1. 生成规划
  const plan = await generatePlan(taskDescription)

  // 2. 判断是否需要人类确认
  if (plan.requiresHumanConfirm) {
    // 3. 调用 Claude Monitor UI 发送通知
    const response = await fetch('http://localhost:8083/api/notification/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        level: 'P2',
        type: 'plan_confirm',
        taskId: currentTaskId,
        title: '任务规划待确认',
        content: plan.summary,
        details: {
          planSummary: plan.summary,
          estimatedTime: plan.estimatedTime,
          risks: plan.risks
        },
        channels: ['feishu', 'in-app'],
        timeout: 7200000,
        actions: [
          { label: '✅ 确认执行', value: 'confirm', type: 'primary' },
          { label: '✏️ 修改计划', value: 'modify', type: 'default' }
        ]
      })
    })

    const { notifyId } = await response.json()

    // 4. 等待确认
    await waitForConfirmation(notifyId)

    // 5. 确认后继续执行
    return continueExecution()
  }

  // 不需要确认，直接执行
  return executePlanImmediately(plan)
}
```

### 在任务阻塞时

```javascript
async function handleBlock(reason) {
  // 更新任务状态为阻塞
  await updateTaskStatus('blocked')

  // 发送通知请求人类介入
  await fetch('http://localhost:8083/api/notification/send', {
    method: 'POST',
    body: JSON.stringify({
      level: 'P1',
      type: 'blocked',
      taskId: currentTaskId,
      title: '任务阻塞需要介入',
      content: `阻塞原因：${reason}`,
      channels: ['feishu', 'email'],
      timeout: 1800000  // 30 分钟
    })
  })

  // 暂停任务，等待人类处理
  return pauseTask()
}
```

---

## 🔐 确认凭证机制

### 凭证结构

```javascript
const ConfirmationToken = {
  notifyId: 'notify-20260303-001',     // 通知 ID
  taskId: 'task-52',                    // 任务 ID
  userId: 'user-001',                   // 用户 ID
  action: 'confirm',                    // 用户操作
  timestamp: '2026-03-03T10:30:00Z',   // 确认时间
  channel: 'feishu',                    // 确认渠道
  signature: 'abc123xyz'                // 签名（防伪造）
}
```

### 凭证验证流程

```javascript
function verifyConfirmation(token) {
  // 1. 验证签名
  if (!verifySignature(token.signature)) {
    throw new Error('无效的确认凭证')
  }

  // 2. 检查是否已使用
  if (isTokenUsed(token.notifyId)) {
    throw new Error('确认凭证已使用，请勿重复确认')
  }

  // 3. 标记为已使用
  markTokenAsUsed(token.notifyId)

  // 4. 记录确认日志
  logConfirmation(token)

  // 5. 触发后续流程
  triggerNextStep(token.taskId, token.action)

  return true
}
```

---

## 📊 数据模型

### 通知配置

```json
{
  "notification": {
    "primaryChannel": "feishu",
    "backupChannels": ["dingtalk", "sms"],
    "channels": {
      "feishu": {
        "enabled": true,
        "webhook": "https://open.feishu.cn/open-apis/bot/v2/hook/xxx",
        "status": "connected"
      },
      "sms": {
        "enabled": true,
        "provider": "aliyun",
        "accessKey": "xxx",
        "phone": "+8613800138000",
        "status": "connected"
      }
    },
    "timeoutSettings": {
      "P0": 300000,
      "P1": 1800000,
      "P2": 7200000,
      "P3": 86400000
    }
  }
}
```

---

## 📚 使用示例

### 完整流程示例

```javascript
// 1. 会话启动
checkPlugins()
readDocuments()
const nextTask = getNextTask()

// 2. 任务规划
const plan = await generatePlan(nextTask.description)

// 3. 发送确认通知
const { notifyId } = await sendNotification({
  level: 'P2',
  type: 'plan_confirm',
  taskId: nextTask.id,
  title: '任务规划待确认',
  content: plan.summary,
  channels: ['feishu', 'in-app']
})

// 4. 等待确认（由 Claude Monitor UI 处理）
// 用户确认后，自动触发回调
onConfirmation(notifyId, (action) => {
  if (action === 'confirm') {
    // 5. 开始执行
    updateTaskStatus('in_progress')
    executeTDD()
  }
})

// 6. TDD 执行完成
const testResults = await runTests()

// 7. 发送完成通知
await sendNotification({
  level: 'P3',
  type: 'task_completed',
  taskId: nextTask.id,
  title: '任务完成',
  content: `测试通过：${testResults.passed}/${testResults.total}`,
  channels: ['in-app']
})

// 8. 更新任务状态
await updateTaskStatus('completed')
```

---

*版本：1.0.0*
*最后更新：2026-03-03*
