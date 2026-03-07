# 脚本使用说明

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

本目录包含项目的所有自动化脚本，用于记忆管理、状态保存、定期同步等功能。

---

## 📁 脚本列表

| 脚本 | 用途 | 频率 | 优先级 |
|------|------|------|--------|
| init-memory.sh | 初始化记忆系统 | 一次性 | P1 |
| checkpoint.sh | 检查点管理 | 按需 | P1 |
| sync-hourly.sh | 小时同步 | 每小时 | P2 |
| archive-daily.sh | 日终归档 | 每日 23:00 | P2 |
| summarize-weekly.sh | 周度总结 | 每周日 22:00 | P3 |
| save-state.sh | 保存状态 | 按需 | P1 |
| restore-state.sh | 恢复状态 | 按需 | P1 |

---

## 🚀 快速开始

### 1. 初始化记忆系统

```bash
# 在新项目中首次运行
./scripts/init-memory.sh

# 功能：
# - 创建 MEMORY.md
# - 创建 AGENTS.md
# - 创建 HEARTBEAT.md
# - 创建 memory/ 目录
# - 创建 checkpoints/ 目录
```

### 2. 开始任务

```bash
# 开始任务 52
./scripts/checkpoint.sh start 52

# 功能：
# - 创建任务检查点
# - 记录开始时间
# - 保存当前状态
```

### 3. 保存状态

```bash
# 保存当前状态
./scripts/save-state.sh "完成需求分析"

# 功能：
# - 保存任务进度
# - 记录关键决策
# - 创建状态快照
```

---

## 📚 详细说明

### init-memory.sh

**用途**：初始化长期记忆系统

**使用场景**：
- 新项目首次配置
- 重置记忆系统

**命令**：
```bash
./scripts/init-memory.sh
```

**执行流程**：
1. 检查必要目录
2. 从模板创建文件
3. 初始化 Git（如果需要）
4. 创建首个检查点

**输出文件**：
- `MEMORY.md` - 长期记忆
- `AGENTS.md` - Agent 行为规范
- `HEARTBEAT.md` - 心跳任务
- `memory/` - 每日日志目录
- `checkpoints/` - 检查点目录

---

### checkpoint.sh

**用途**：管理任务检查点

**使用场景**：
- 开始新任务
- 查看任务状态
- 完成任务

**命令**：
```bash
# 开始任务
./scripts/checkpoint.sh start <task_id>

# 查看状态
./scripts/checkpoint.sh status <task_id>

# 完成任务
./scripts/checkpoint.sh complete <task_id>

# 列出所有检查点
./scripts/checkpoint.sh list
```

**示例**：
```bash
# 开始任务 52
./scripts/checkpoint.sh start 52

# 查看任务 52 状态
./scripts/checkpoint.sh status 52

# 完成任务 52
./scripts/checkpoint.sh complete 52
```

**检查点文件格式**：
```json
{
  "checkpointId": "checkpoint-task-52-20260307-150000",
  "taskId": "task-52",
  "timestamp": "2026-03-07T15:00:00+08:00",
  "type": "start",
  "state": {
    "phase": "planning",
    "progress": 0
  }
}
```

---

### sync-hourly.sh

**用途**：每小时同步记忆

**使用场景**：
- 自动定时执行（cron）
- 手动触发同步

**命令**：
```bash
./scripts/sync-hourly.sh
```

**执行流程**：
1. 读取当前会话状态
2. 记录技术决策和待办
3. 更新 `memory/YYYY-MM-DD.md`
4. 更新 `.heartbeat-status.json`

**配置 cron**：
```bash
# 编辑 crontab
crontab -e

# 添加每小时执行
0 * * * * cd /path/to/project && ./scripts/sync-hourly.sh
```

---

### archive-daily.sh

**用途**：每日归档记忆

**使用场景**：
- 每日 23:00 自动执行
- 手动触发归档

**命令**：
```bash
./scripts/archive-daily.sh
```

**执行流程**：
1. 读取当日 memory 文件
2. 提取重要决策和教训
3. 更新 MEMORY.md 相关章节
4. 生成日报摘要
5. 准备明日待办

**配置 cron**：
```bash
# 每日 23:00 执行
0 23 * * * cd /path/to/project && ./scripts/archive-daily.sh
```

---

### summarize-weekly.sh

**用途**：周度总结记忆

**使用场景**：
- 每周日 22:00 自动执行
- 手动触发总结

**命令**：
```bash
./scripts/summarize-weekly.sh
```

**执行流程**：
1. 读取过去 7 天的 memory 文件
2. 提取关键决策和模式
3. 更新 MEMORY.md
4. 清理过时信息
5. 生成周报

**配置 cron**：
```bash
# 每周日 22:00 执行
0 22 * * 0 cd /path/to/project && ./scripts/summarize-weekly.sh
```

---

### save-state.sh

**用途**：保存当前状态

**使用场景**：
- 关键节点保存
- 上下文达到 80% 时
- 任务暂停前

**命令**：
```bash
./scripts/save-state.sh "原因说明"
```

**示例**：
```bash
# 完成需求分析后保存
./scripts/save-state.sh "完成需求分析"

# 上下文压缩前保存
./scripts/save-state.sh "上下文达到 80%"
```

**保存内容**：
- 当前任务 ID 和进度
- 关键变量和决策
- 测试结果
- 修改的文件列表

---

### restore-state.sh

**用途**：恢复之前的状态

**使用场景**：
- 任务中断后恢复
- Compact 后恢复上下文
- 切换任务

**命令**：
```bash
# 恢复最新状态
./scripts/restore-state.sh latest

# 恢复特定检查点
./scripts/restore-state.sh <checkpoint_id>

# 列出可用检查点
./scripts/restore-state.sh list
```

**示例**：
```bash
# 恢复最新状态
./scripts/restore-state.sh latest

# 恢复特定检查点
./scripts/restore-state.sh checkpoint-task-52-20260307-150000
```

---

## 🔧 配置

### 环境变量

```bash
# 项目根目录
export PROJECT_ROOT="/path/to/project"

# 记忆目录
export MEMORY_DIR="$PROJECT_ROOT/memory"

# 检查点目录
export CHECKPOINT_DIR="$PROJECT_ROOT/checkpoints"
```

### 自动化配置

```bash
# 编辑 crontab
crontab -e

# 添加以下内容
# 每小时同步
0 * * * * cd /path/to/project && ./scripts/sync-hourly.sh

# 每日归档（23:00）
0 23 * * * cd /path/to/project && ./scripts/archive-daily.sh

# 每周总结（周日 22:00）
0 22 * * 0 cd /path/to/project && ./scripts/summarize-weekly.sh
```

---

## 🎯 使用场景

### 场景 1: 开始新任务

```bash
# 1. 开始任务
./scripts/checkpoint.sh start 52

# 2. 工作中定期保存
./scripts/save-state.sh "完成需求分析"
./scripts/save-state.sh "完成测试编写"

# 3. 完成任务
./scripts/checkpoint.sh complete 52
```

### 场景 2: 任务中断恢复

```bash
# 1. 列出可用检查点
./scripts/restore-state.sh list

# 2. 恢复最新状态
./scripts/restore-state.sh latest

# 3. 继续任务
./scripts/checkpoint.sh status 52
```

### 场景 3: 上下文管理

```bash
# 上下文达到 80% 时
./scripts/save-state.sh "上下文达到 80%"

# Compact 后恢复
./scripts/restore-state.sh latest
```

---

## ❓ 常见问题

### Q1: 脚本执行权限问题

**A**: 添加执行权限

```bash
chmod +x scripts/*.sh
```

### Q2: cron 任务不执行

**A**: 检查 cron 日志

```bash
# macOS
tail -f /var/log/system.log | grep cron

# Linux
tail -f /var/log/syslog | grep CRON
```

### Q3: 检查点文件过多

**A**: 定期清理旧检查点

```bash
# 删除 30 天前的检查点
find checkpoints/ -name "*.json" -mtime +30 -delete
```

### Q4: 记忆文件过大

**A**: 归档旧记忆

```bash
# 移动到归档目录
mkdir -p .memory-archive
mv memory/2026-01-*.md .memory-archive/
```

---

## 🔗 相关文档

- [长期记忆管理规范](../guidelines/11-LONG_TERM_MEMORY.md)
- [长期运行 Agent 最佳实践](../guidelines/08-LONG_RUNNING_AGENTS.md)
- [Anthropic 官方指南](../guidelines/10-ANTHROPIC_LONG_RUNNING_AGENTS.md)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|---------|
| 2026-03-07 | 1.0.0 | 初始版本，包含所有脚本说明 |

---

> **提示**：建议配置 cron 自动执行定期任务，确保记忆系统持续运行。
