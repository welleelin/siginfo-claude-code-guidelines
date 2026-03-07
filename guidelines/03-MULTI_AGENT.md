# 多 Agent 协作

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

多 Agent 协作模式通过专业分工提高开发效率和代码质量。

---

## 🤖 可用 Agent

| Agent | 职责 | 使用场景 |
|-------|------|---------|
| **planner** | 任务规划 | 复杂功能、重构 |
| **architect** | 系统设计 | 架构决策 |
| **tdd-guide** | 测试驱动开发 | 新功能、Bug 修复 |
| **code-reviewer** | 代码审查 | 完成代码后 |
| **security-reviewer** | 安全审查 | 提交前 |
| **build-error-resolver** | 构建修复 | 构建失败时 |
| **e2e-runner** | E2E 测试 | 关键流程 |
| **refactor-cleaner** | 代码清理 | 代码维护 |
| **doc-updater** | 文档更新 | 文档维护 |

---

## 🔄 协作模式

### 模式 1: 串行协作

```
planner → tdd-guide → code-reviewer → e2e-runner
```

**适用场景**：单一功能开发

### 模式 2: 并行协作

```
Agent 1: 后端 API
Agent 2: 前端页面
Agent 3: 数据库设计
```

**适用场景**：独立模块开发

### 模式 3: 团队模式

```
architect → planner → [tdd-guide, code-reviewer] → e2e-runner
```

**适用场景**：复杂功能从 0 到 1

---

## 📝 使用示例

### 示例 1: 新功能开发

```bash
# 1. 规划
/plan "实现用户登录功能"

# 2. TDD 开发
/tdd

# 3. 代码审查
/code-review

# 4. E2E 测试
/e2e
```

### 示例 2: 并行开发

```bash
# 同时启动多个 Agent
Agent 1: 开发后端 API
Agent 2: 开发前端页面
Agent 3: 编写测试用例
```

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md)
- [TDD 开发流程](02-TDD_WORKFLOW.md)

---

*版本：1.0.0 | 最后更新：2026-03-07*
