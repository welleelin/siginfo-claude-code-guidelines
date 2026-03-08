# 上下文管理配置

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：配置上下文监控、自动保存和压缩机制

---

## 📋 概述

本文档定义上下文管理的配置规范，确保在上下文接近限制时自动保存和压缩。

---

## 📊 Model 上下文配额

| Model | Context Limit | 预警线 (70%) | 压缩线 (80%) | 强制线 (90%) |
|-------|--------------|-------------|-------------|-------------|
| claude-sonnet-4 | 200k tokens | 140k | 160k | 180k |
| claude-opus-4 | 200k tokens | 140k | 160k | 180k |
| qwen3.5-plus | 91k tokens | 63.7k | 72.8k | 81.9k |
| gemini-2.5-pro | 128k tokens | 89.6k | 102.4k | 115.2k |

---

## 🔄 上下文监控机制

### 监控流程

```
┌─────────────────────────────────────────────────────────────────┐
│                    上下文监控流程                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  每 30 秒检测 ──▶ 计算使用率 ──▶ 判断阈值                        │
│                                     │                           │
│         ┌───────────────────────────┼───────────────────────┐   │
│         │                           │                       │   │
│         ▼                           ▼                       ▼   │
│    70% 预警                    80% 准备压缩            90% 强制压缩  │
│         │                           │                       │   │
│         ▼                           ▼                       ▼   │
│    发送 P2 通知               自动保存关键信息         自动执行 compact  │
│    提醒用户                   到 MEMORY.md            保存状态后压缩    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 阈值触发动作

| 阈值 | 触发动作 | 通知级别 | 说明 |
|------|---------|---------|------|
| 70% | 预警通知 | P2 | 提醒用户上下文使用量较高 |
| 80% | 自动保存到 Memory | P2 | 保存关键信息到 MEMORY.md |
| 90% | 强制 compact | P1 | 自动执行 compact 并恢复状态 |

---

## 💾 自动保存机制

### 保存触发条件

当上下文使用率达到 80% 时，自动触发 Memory 保存：

```javascript
// 自动保存的关键信息
const criticalInfo = {
  taskId: 'task-52',              // 当前任务 ID
  taskProgress: 'implementation',  // 任务阶段
  currentStep: '编写登录页面组件',  // 当前步骤
  variables: { ... },             // 关键变量
  decisions: [                    // 重要决策
    {
      timestamp: '2026-03-08T10:00:00Z',
      decision: '选择方案 A',
      reason: '性能更好'
    }
  ],
  testResults: { ... },           // 测试结果
  filesModified: [...]            // 修改的文件列表
}

// 保存到 MEMORY.md
await saveToMemory(criticalInfo)
```

### 保存内容

**必须保存的信息**：
- 当前任务 ID 和进度
- 任务阶段和当前步骤
- 关键变量和决策
- 测试结果
- 修改的文件列表
- Mock 接口登记
- 测试模式约束

**保存位置**：
- `MEMORY.md` - 持久化约束区域
- `memory/YYYY-MM-DD.md` - 当日日志
- `checkpoints/checkpoint-*.json` - 状态检查点

---

## 🗜️ 自动 Compact 流程

### Compact 触发条件

当上下文使用率达到 90% 时，自动触发 compact：

```
1. 检测到 90% 阈值
   ↓
2. 保存当前状态
   ↓
3. 生成状态快照
   ↓
4. 执行 compact 命令
   ↓
5. 等待 compact 完成
   ↓
6. 读取 MEMORY.md 恢复上下文
   ↓
7. 继续执行任务
```

### Compact 前保存

**保存内容**：
```json
{
  "taskId": "task-52",
  "taskProgress": "implementation",
  "currentStep": "编写登录页面组件",
  "keyDecisions": [
    {
      "timestamp": "2026-03-08T10:00:00Z",
      "decision": "选择 Zustand 作为状态管理",
      "reason": "轻量、性能好"
    }
  ],
  "testResults": {
    "passed": 3,
    "failed": 0,
    "pending": 2
  },
  "filesModified": [
    "src/views/login/index.vue",
    "src/api/auth.ts"
  ],
  "mockInterfaces": [
    {
      "interface": "/api/xxx",
      "reason": "接口未开发",
      "expectedReplaceDate": "2026-03-15"
    }
  ],
  "testingConstraints": {
    "mockAllowed": ["前端开发阶段", "前端 Mock 测试"],
    "mockForbidden": ["后端 API 测试", "前后端联调", "E2E 测试"]
  }
}
```

### Compact 后恢复

**恢复检查清单**：

```
□ 1. 读取 MEMORY.md 持久化区域
   - 确认测试状态
   - 确认 Mock 模式使用状态

□ 2. 验证约束条件
   - Mock 模式是否仅在允许阶段使用
   - 联调测试是否已切换到真实 API

□ 3. 检查测试报告
   - 确认报告未包含 Mock 测试（前端除外）
   - 确认所有 Mock 接口都有标记

□ 4. 继续任务前确认
   - 如有未完成的真实 API 测试，优先执行
   - 如有未标记的 Mock 接口，补充标记
```

---

## 🛠️ 配置方式

### 方式 1: 环境变量配置

```bash
# 设置上下文阈值
export CONTEXT_WARNING_THRESHOLD=70
export CONTEXT_COMPACT_THRESHOLD=90

# 设置检查间隔（秒）
export CONTEXT_CHECK_INTERVAL=30

# 启用自动保存
export AUTO_SAVE_ENABLED=true

# 启用自动 compact
export AUTO_COMPACT_ENABLED=true
```

### 方式 2: 配置文件

创建 `.unified/config/context-config.json`：

```json
{
  "monitoring": {
    "enabled": true,
    "checkInterval": 30,
    "warningThreshold": 70,
    "compactThreshold": 90
  },
  "autoSave": {
    "enabled": true,
    "triggerThreshold": 80,
    "saveLocation": "MEMORY.md"
  },
  "autoCompact": {
    "enabled": true,
    "triggerThreshold": 90,
    "saveStateBeforeCompact": true,
    "restoreStateAfterCompact": true
  },
  "notifications": {
    "warningLevel": "P2",
    "compactLevel": "P1",
    "channels": ["in-app"]
  }
}
```

### 方式 3: 在 CLAUDE.md 中配置

在项目根目录的 `CLAUDE.md` 中添加：

```markdown
## 📊 上下文管理

| Model | Context Limit | 预警线 (70%) | 压缩线 (80%) | 强制线 (90%) |
|-------|--------------|-------------|-------------|-------------|
| claude-sonnet-4 | 200k | 140k | 160k | 180k |

**自动化配置**：
- ✅ 上下文监控已启用（每 30 秒检查）
- ✅ 自动保存已启用（80% 触发）
- ✅ 自动 compact 已启用（90% 触发）
```

---

## 🔍 监控与调试

### 查看当前上下文使用量

```bash
# 查看上下文使用情况
# （需要 Claude Code 支持）
/context usage
```

### 手动触发 compact

```bash
# 手动执行 compact
/context compact
```

### 查看上下文历史

```bash
# 查看最近 24 小时的上下文使用历史
/context history --hours 24
```

### 配置阈值

```bash
# 配置预警和压缩阈值
/context config set --warning 70 --compact 90
```

---

## 📝 配置验证清单

### 部署前检查

- [ ] 上下文阈值已配置
- [ ] 自动保存机制已启用
- [ ] 自动 compact 机制已启用
- [ ] 通知渠道已配置
- [ ] MEMORY.md 持久化区域已准备

### 部署后检查

- [ ] 上下文监控正常工作
- [ ] 达到 70% 时发送预警
- [ ] 达到 80% 时自动保存
- [ ] 达到 90% 时自动 compact
- [ ] Compact 后状态正常恢复

---

## 🔗 相关文档

- [系统总则](../../guidelines/00-SYSTEM_OVERVIEW.md) - 上下文管理原则
- [长期记忆管理规范](../../guidelines/11-LONG_TERM_MEMORY.md) - Memory 保存机制
- [长期运行 Agent 最佳实践](../../guidelines/08-LONG_RUNNING_AGENTS.md) - 状态管理

---

*版本：1.0.0 | 创建日期：2026-03-08*
