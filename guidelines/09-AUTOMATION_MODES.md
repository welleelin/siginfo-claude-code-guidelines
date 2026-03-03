# 项目级自动化模式配置指南

> 为每个窗口/项目配置独立的自动化开发执行模式

---

## 📋 概述

本指南说明如何在每个窗口或项目上配置自动化开发执行模式，基于行动准则实现：

- **自动任务分解** - 将大任务分解为可执行的小步骤
- **自动执行** - 按照配置的模式自动执行任务
- **自动验证** - 执行后自动验证结果
- **异常处理** - 遇到异常时自动处理或通知人类

---

## 🎯 核心概念

### 自动化模式 (Automation Profile)

自动化模式定义了一组执行规则，包括：

```json
{
  "modeId": "tdd-standard",
  "modeName": "TDD 开发模式",
  "description": "标准 TDD 开发流程",
  "steps": [
    "需求分析",
    "编写测试",
    "运行测试 (确认失败)",
    "实现功能",
    "运行测试 (确认通过)",
    "重构优化",
    "验证闭环"
  ],
  "autoExecute": true,
  "humanConfirmPoints": [
    "需求分析完成后",
    "测试失败确认后"
  ],
  "contextManagement": {
    "enabled": true,
    "warningThreshold": 70,
    "compactThreshold": 90,
    "autoSaveToMemory": true
  },
  "errorHandling": {
    "maxRetries": 3,
    "retryInterval": 60,
    "escalateAfterRetries": true
  }
}
```

### 可用模式

| 模式 ID | 模式名称 | 自动执行 | 适用场景 |
|--------|---------|---------|---------|
| `tdd-standard` | TDD 开发模式 | ✅ | 新功能开发 |
| `code-review-standard` | 代码审查模式 | ✅ | 代码审查 |
| `refactor-safe` | 安全重构模式 | ⚠️ 需确认 | 代码重构 |
| `bug-fix-standard` | Bug 修复模式 | ⚠️ 需确认 | Bug 修复 |
| `test-generation` | 测试生成模式 | ✅ | 生成测试 |
| `documentation` | 文档生成模式 | ✅ | 生成文档 |

---

## 🔧 配置方式

### 方式 1：通过前端配置页面

1. 打开项目管理页面
2. 选择要配置的项目/窗口
3. 点击「自动化模式配置」
4. 选择预设模式或自定义模式
5. 配置人类介入点
6. 配置上下文管理阈值
7. 保存配置

### 方式 2：通过 API 配置

```bash
# 获取可用模式列表
GET /api/automation/modes

# 获取项目当前配置
GET /api/automation/profiles?projectId=proj-001

# 应用模式到项目
POST /api/automation/apply
{
  "projectId": "proj-001",
  "modeId": "tdd-standard",
  "customConfig": {
    "humanConfirmPoints": ["需求分析完成后"],
    "contextManagement": {
      "warningThreshold": 70
    }
  }
}

# 更新配置
POST /api/automation/profiles
{
  "projectId": "proj-001",
  "config": { ... }
}
```

### 方式 3：通过 CLAUDE.md 配置

在项目根目录的 `CLAUDE.md` 中添加：

```markdown
## 自动化模式配置

本项目使用以下自动化模式：

```json
{
  "defaultMode": "tdd-standard",
  "modes": {
    "tdd-standard": {
      "enabled": true,
      "humanConfirmPoints": ["需求分析完成后", "测试失败确认后"],
      "contextManagement": {
        "warningThreshold": 70,
        "compactThreshold": 90
      }
    },
    "code-review-standard": {
      "enabled": true,
      "humanConfirmPoints": ["问题分类完成后"]
    }
  }
}
```
```

---

## 📊 自动化执行流程

### 完整流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                    自动化开发执行流程                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 接收任务                                                    │
│         │                                                       │
│         ▼                                                       │
│  2. 读取项目自动化模式配置                                       │
│         │                                                       │
│         ▼                                                       │
│  3. 自动分解任务为步骤                                          │
│         │                                                       │
│         ▼                                                       │
│  4. 执行步骤 1                                                   │
│         │                                                       │
│         ▼                                                       │
│  5. 检查是否需要人类确认 ──── 是 ────▶ 发送通知等待确认          │
│         │                                                       │
│        否                                                       │
│         │                                                       │
│         ▼                                                       │
│  6. 检查上下文使用率                                            │
│         │                                                       │
│         ▼                                                       │
│  70% 以下 ────▶ 继续执行                                        │
│         │                                                       │
│         ▼                                                       │
│  70-80% ────▶ 发送预警，继续执行                                │
│         │                                                       │
│         ▼                                                       │
│  80-90% ────▶ 自动保存到 Memory，继续执行                        │
│         │                                                       │
│         ▼                                                       │
│  90% 以上 ────▶ 自动 compact，恢复状态，继续执行                 │
│         │                                                       │
│         ▼                                                       │
│  8. 检查执行结果                                                │
│         │                                                       │
│         ▼                                                       │
│  成功 ────▶ 记录进度，执行下一步                                 │
│         │                                                       │
│         ▼                                                       │
│  失败 ────▶ 错误分级处理                                        │
│               │                                                 │
│               ├── L1：自动重试                                  │
│               ├── L2：尝试备选方案                              │
│               └── L3：通知人类介入                              │
│                                                                 │
│         ▼                                                       │
│  9. 所有步骤完成 ────▶ 生成执行报告                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 步骤执行示例

以 TDD 模式开发"用户登录功能"为例：

```
任务：实现用户登录功能

应用模式：tdd-standard

执行步骤：

1. 【自动】需求分析
   - 分析任务描述
   - 识别功能需求
   - 输出：需求摘要

2. 【人类确认】需求分析完成
   - 发送通知：需求分析已完成，请确认
   - 等待用户确认

3. 【自动】编写测试用例
   - 创建测试文件 e2e/login.spec.ts
   - 编写登录成功测试
   - 编写登录失败测试
   - 输出：测试用例

4. 【自动】运行测试（确认失败）
   - 执行：npx playwright test e2e/login.spec.ts
   - 预期结果：测试失败（因为功能尚未实现）
   - 输出：测试失败报告

5. 【自动】实现功能
   - 创建登录页面 views/login/index.vue
   - 实现表单验证逻辑
   - 实现 API 调用
   - 输出：功能代码

6. 【自动】运行测试（确认通过）
   - 执行：npx playwright test e2e/login.spec.ts
   - 结果：测试通过
   - 输出：测试通过报告

7. 【自动】重构优化
   - 分析代码质量
   - 优化代码结构
   - 输出：重构后的代码

8. 【自动】验证闭环
   - 运行全部相关测试
   - 检查构建是否成功
   - 输出：验证报告

9. 【自动】生成执行报告
   - 任务完成
   - 测试通过率：100%
   - 修改文件：3 个
   - 执行时间：45 分钟
```

---

## 📋 配置选项详解

### 人类介入点配置

```json
{
  "humanConfirmPoints": [
    {
      "step": "需求分析完成后",
      "notifyLevel": "P2",
      "channels": ["feishu", "in-app"],
      "timeout": 7200000,
      "actions": ["confirm", "modify", "skip"]
    },
    {
      "step": "测试失败确认后",
      "notifyLevel": "P2",
      "channels": ["in-app"],
      "timeout": 3600000,
      "actions": ["confirm", "retry"]
    }
  ]
}
```

### 上下文管理配置

```json
{
  "contextManagement": {
    "enabled": true,
    "checkInterval": 30000,
    "warningThreshold": 70,
    "prepareCompactThreshold": 80,
    "forceCompactThreshold": 90,
    "autoActions": {
      "atWarning": "notify",
      "atPrepareCompact": "save_memory",
      "atForceCompact": "auto_compact"
    }
  }
}
```

### 错误处理配置

```json
{
  "errorHandling": {
    "enabled": true,
    "maxRetries": 3,
    "retryInterval": 60000,
    "retryBackoff": "exponential",
    "escalateAfterRetries": true,
    "escalateLevel": "P1",
    "errorLevels": {
      "L1": ["network_timeout", "temporary_failure"],
      "L2": ["api_unavailable", "resource_not_found"],
      "L3": ["permission_denied", "data_corruption"]
    }
  }
}
```

### 进度追踪配置

```json
{
  "progressTracking": {
    "enabled": true,
    "logInterval": 300000,
    "reportInterval": 3600000,
    "saveToMemory": true,
    "notifyOnComplete": true
  }
}
```

---

## 🔍 监控与调试

### 查看执行状态

```bash
# 查看当前自动化执行状态
GET /api/automation/status?projectId=proj-001

# 响应
{
  "success": true,
  "projectId": "proj-001",
  "mode": "tdd-standard",
  "currentStep": "实现功能",
  "progress": 60,
  "steps": [
    { "name": "需求分析", "status": "completed" },
    { "name": "编写测试", "status": "completed" },
    { "name": "运行测试", "status": "completed" },
    { "name": "实现功能", "status": "in_progress" },
    { "name": "重构优化", "status": "pending" },
    { "name": "验证闭环", "status": "pending" }
  ]
}
```

### 查看执行历史

```bash
# 查看执行历史
GET /api/automation/history?projectId=proj-001&days=7

# 响应
{
  "success": true,
  "history": [
    {
      "taskId": "task-52",
      "mode": "tdd-standard",
      "startedAt": "2026-03-03T10:00:00Z",
      "completedAt": "2026-03-03T10:45:00Z",
      "status": "completed",
      "result": "success",
      "stepsCompleted": 6,
      "humanConfirmations": 2,
      "errors": 0,
      "contextCompactions": 1
    }
  ]
}
```

### 调试模式

```bash
# 启用调试模式
POST /api/automation/debug
{
  "projectId": "proj-001",
  "enabled": true,
  "logLevel": "verbose"
}

# 调试模式会：
# - 记录每个步骤的详细日志
# - 保存中间状态
# - 输出更多上下文信息
```

---

## 📚 最佳实践

### 1. 根据项目类型选择模式

| 项目类型 | 推荐模式 | 说明 |
|---------|---------|------|
| 新功能开发 | tdd-standard | 完整 TDD 流程 |
| 代码优化 | refactor-safe | 安全重构，需要确认 |
| Bug 修复 | bug-fix-standard | 定位问题后确认方案 |
| 测试补充 | test-generation | 自动生成测试 |
| 文档补充 | documentation | 自动生成文档 |

### 2. 合理配置人类介入点

**推荐配置**：
- 需求分析完成后（确保方向正确）
- 测试失败确认后（确认可以开始实现）
- 架构决策点（选择技术方案）
- 风险评估后（确认是否接受风险）

**不推荐配置**：
- 每个步骤都确认（效率太低）
- 简单操作也确认（如格式化代码）

### 3. 监控上下文使用

- 启用自动上下文管理
- 设置合理的阈值（70%/80%/90%）
- 启用自动保存到 Memory
- 启用自动 compact

### 4. 逐步建立信任

**第一阶段**（1-2 周）：
- 启用自动化，但所有人类介入点都确认
- 观察自动化执行情况
- 调整配置

**第二阶段**（2-4 周）：
- 减少非必要的人类介入点
- 增加自动执行比例
- 建立信任

**第三阶段**（4 周+）：
- 只在关键点介入
- 大部分自动执行
- 定期审查执行报告

---

## 🔗 相关文档

- [系统总则](00-SYSTEM_OVERVIEW.md) - 上下文管理
- [长期运行 Agent 最佳实践](08-LONG_RUNNING_AGENTS.md) - 核心原则
- [API 接口](../docs/API_INTEGRATION.md) - 自动化 API

---

*版本：1.0.0*
*最后更新：2026-03-03*
