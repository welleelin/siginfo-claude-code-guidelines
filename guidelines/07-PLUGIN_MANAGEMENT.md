# 插件管理

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

插件管理规范定义了必备插件、安装方法和使用场景。

---

## 🔌 必备插件

| 插件名称 | 用途 | 安装方式 | 是否必备 |
|---------|------|---------|---------|
| **bmad-method** | 需求分析、架构设计 | `/plugin install bmad-method` | ✅ 必备 |
| **everything-claude-code** | 命令库、技能库 | 手动安装 | ✅ 必备 |
| **workflow-studio** | 流程图、时序图 | `/plugin install workflow-studio` | ✅ 必备 |
| **pencil** | UI 设计原型 | MCP 服务 | ✅ 必备 |

---

## 🚀 插件初始化

### 检查已安装插件

```bash
/plugin list
```

### 安装缺失插件

```bash
# 安装 bmad-method
/plugin install bmad-method

# 安装 workflow-studio
/plugin install workflow-studio

# 安装 everything-claude-code
# 需要手动安装
```

### 验证插件状态

```bash
# 检查插件是否正常工作
/plugin list

# 验证必备插件
必需插件：
- bmad-method ✅
- everything-claude-code ✅
- workflow-studio ✅
- pencil ✅
```

---

## 📊 插件使用场景

| 阶段 | 使用插件 | 具体能力 |
|------|---------|---------|
| **需求分析** | bmad-method | `bmm-create-product-brief` |
| **架构设计** | bmad-method + pencil | `bmm-create-architecture` |
| **任务规划** | everything-claude-code | `/plan` 命令 |
| **TDD 开发** | everything-claude-code | `/tdd` 命令 |
| **UI 设计** | pencil | 创建页面原型 |
| **流程设计** | workflow-studio | 创建流程图 |
| **代码审查** | everything-claude-code | `/code-review` |
| **E2E 测试** | everything-claude-code | `/e2e` 命令 |

---

## 🔗 相关文档

- [行动准则](01-ACTION_GUIDELINES.md)
- [系统总则](00-SYSTEM_OVERVIEW.md)

---

*版本：1.0.0 | 最后更新：2026-03-07*
