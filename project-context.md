# 项目上下文 - sig-claude-code-guidelines

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **最后更新**：2026-03-08

---

## 📋 项目概述

**项目名称**：sig-claude-code-guidelines

**项目定位**：一套经过实战验证的 AI 辅助软件开发规范，让团队开发像流水线一样高效

**项目类型**：开发规范与流程框架

---

## 🛠️ 技术栈

### 核心技术

| 技术 | 版本 | 用途 |
|------|------|------|
| Shell/Bash | - | 自动化脚本 |
| Markdown | - | 文档编写 |
| YAML | - | 配置文件 |
| JSON | - | 数据存储 |

### 开发工具

| 工具 | 版本 | 用途 |
|------|------|------|
| Git | 2.x | 版本控制 |
| Claude Code | latest | AI 辅助开发 |
| BMAD Method | v6.0.4 | 需求分析与规划 |

---

## 📐 架构设计

### 项目结构

```
sig-claude-code-guidelines/
├── guidelines/          # 14 个核心规范文档
├── scripts/            # 自动化脚本
├── templates/          # 模板文件
├── docs/               # 文档
├── memory/             # 每日记忆日志
├── checkpoints/        # 状态检查点
├── _bmad/              # BMAD Method 核心
├── _bmad-output/       # BMAD Method 产出
└── .unified/           # 统一配置目录
```

### 核心模块

1. **Guidelines 模块**：14 个核心规范文档
2. **Scripts 模块**：记忆管理、检查点、验证脚本
3. **Memory 模块**：三层记忆系统（Hourly/Daily/Weekly）
4. **BMAD 模块**：需求分析、架构设计、Story 驱动开发

---

## 🎯 开发规范

### 代码风格

- **Shell 脚本**：遵循 Google Shell Style Guide
- **Markdown**：遵循 CommonMark 规范
- **命名规范**：kebab-case（文件名）、UPPER_CASE（环境变量）

### 文档规范

- 所有文档使用简体中文
- 文档结构清晰，使用标题层级
- 代码示例使用代码块，标注语言
- 表格用于对比和列表

### Git 规范

- 提交信息格式：`<type>: <description>`
- 类型：feat, fix, docs, refactor, test, chore
- 分支策略：main（主分支）

---

## 🔧 实现规则

### 脚本开发规则

1. **错误处理**：使用 `set -e` 确保错误时退出
2. **日志输出**：使用颜色区分不同级别（info/success/warning/error）
3. **参数验证**：检查必需参数，提供使用说明
4. **幂等性**：脚本可重复执行，不产生副作用

### 文档编写规则

1. **版本信息**：每个文档包含版本号和更新日期
2. **目录结构**：使用 emoji 图标增强可读性
3. **代码示例**：提供完整可运行的示例
4. **相关链接**：文档间相互引用，形成知识网络

### 记忆管理规则

1. **Hourly 层**：实时记录技术决策和待办
2. **Daily 层**：每日归档重要决策和教训
3. **Weekly 层**：周度总结核心知识和最佳实践
4. **分离存储**：敏感信息不写入记忆文件

---

## 🔗 集成项目

### BMAD Method 集成

- **安装位置**：`_bmad/`
- **产出位置**：`_bmad-output/`
- **配置文件**：`_bmad/_config/`
- **使用场景**：需求分析、架构设计、Story 分解

### everything-claude-code 集成（待实施）

- **安装方式**：Git submodule
- **技能库位置**：`~/.claude/skills/`
- **命令位置**：`~/.claude/commands/`
- **使用场景**：快速命令、代码生成、重构优化

### oh-my-claudecode 集成（待实施）

- **安装方式**：Plugin install
- **配置位置**：`.unified/routing/`
- **使用场景**：多 Agent 编排、成本优化、Team 协作

---

## 📊 质量标准

### 文档质量

- 完整性：≥ 90%
- 准确性：100%
- 可读性：清晰易懂
- 可维护性：结构化、模块化

### 脚本质量

- 功能正确性：100%
- 错误处理：完整
- 日志输出：清晰
- 可维护性：注释充分

### 记忆质量

- 信息准确性：100%
- 检索效率：< 100ms
- 存储效率：合理压缩
- 隐私保护：敏感信息分离

---

## 🚀 部署与运维

### 初始化流程

```bash
# 1. 初始化记忆系统
./scripts/init-memory.sh

# 2. 验证环境
./scripts/checkpoint.sh status

# 3. 启动心跳检查
# 配置 cron 任务
```

### 日常维护

```bash
# 每小时同步
./scripts/sync-hourly.sh

# 每日归档（23:00）
./scripts/archive-daily.sh

# 每周总结（周日 22:00）
./scripts/summarize-weekly.sh
```

### 监控指标

- 记忆文件大小：< 20KB（MEMORY.md）
- 检查点数量：保留最近 10 个
- 脚本执行时间：< 5 秒

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-08 | 1.0.0 | 初始版本，集成 BMAD Method | Claude |

---

> **注意**：
> - 本文件存储静态的技术栈和实现规则
> - 动态的决策和教训记录在 MEMORY.md
> - 两者互补，共同构成完整的项目记忆系统
