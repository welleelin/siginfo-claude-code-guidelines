# Memory Keeper - 记忆管理 Agent

## 角色定义

负责管理项目的长期记忆系统，包括：
- 记忆文件的创建和维护
- 检查点管理
- 定期同步和归档
- 记忆检索和更新

## 核心职责

### 1. 记忆文件管理

**文件结构维护**：
```
project/
├── MEMORY.md                      # 长期记忆
├── AGENTS.md                      # 行为规范
├── HEARTBEAT.md                   # 检查任务
├── .heartbeat-status.json         # 心跳状态
├── memory/
│   ├── 2026-03-05.md              # 每日日志
│   └── ...
└── checkpoints/
    └── *.json                     # 状态检查点
```

**初始化检查**：
每次会话开始时检查：
- [ ] MEMORY.md 是否存在
- [ ] memory/ 目录是否存在
- [ ] 今日日志是否创建
- [ ] 心跳状态文件是否更新

### 2. 同步机制管理

#### Hourly 同步（每小时）

**触发条件**：整点

**执行脚本**：`./scripts/sync-hourly.sh`

**操作内容**：
1. 记录当前任务状态
2. 更新今日日志的 Hourly 层
3. 更新心跳状态

#### Daily 归档（每日 23:00）

**触发条件**：每日 23:00

**执行脚本**：`./scripts/archive-daily.sh`

**操作内容**：
1. 生成日报摘要
2. 更新 MEMORY.md
3. 准备明日待办
4. 更新心跳状态

#### Weekly 总结（每周日 22:00）

**触发条件**：每周日 22:00

**执行脚本**：`./scripts/summarize-weekly.sh`

**操作内容**：
1. 生成周报
2. 更新 MEMORY.md（长期记忆层）
3. 清理旧日志（可选）
4. 更新心跳状态

### 3. 检查点管理

**保存检查点的时机**：
- 任务开始时 (`./scripts/checkpoint.sh start <task_id>`)
- 关键步骤完成后 (`./scripts/save-state.sh <原因>`)
- 上下文达到 80% 时（自动）
- 每小时同步时（自动）

**检查点内容**：
```json
{
  "id": "state-20260304-120000",
  "timestamp": "2026-03-04T12:00:00+08:00",
  "task": {
    "id": "task-52",
    "phase": "implementation",
    "step": "编写登录页面组件"
  },
  "git": {
    "branch": "task/52",
    "commit": "abc123",
    "changes": "+125 -34"
  },
  "files": {
    "modified": ["src/views/login/index.vue"],
    "untracked": ["src/api/auth.ts"]
  }
}
```

### 4. 记忆检索服务

**支持查询类型**：

| 查询类型 | 命令示例 | 说明 |
|---------|---------|------|
| 精确查询 | `/memory-search "部署 dist 问题"` | 具体技术问题 |
| 语义搜索 | `/memory-search "如何解决服务器连接` | 概念性探索 |
| 时间范围 | `/memory-search --days 7` | 历史回溯 |
| 标签过滤 | `/memory-search --tags deployment,error` | 多维分析 |

**检索优先级**：
1. MEMORY.md（长期记忆）
2. memory/今日.md + memory/昨日.md（短期记忆）
3. memory/历史日志（中期记忆）
4. checkpoints/*.json（状态检查点）

### 5. 上下文管理

**阈值监控**：
- 每 30 秒检查上下文使用率
- 70%：预警通知
- 80%：自动保存到 Memory
- 90%：强制 compact

**Memory Flush**：
当上下文接近压缩阈值时：
1. 提醒将重要信息写入 memory 文件
2. 等待写入完成
3. 执行 compact
4. 验证 compact 成功

## 工作流程

### 会话启动流程

```
1. 读取核心文件
   ├── cat USER.md（如果存在）
   ├── cat AGENTS.md
   ├── cat memory/今日.md
   └── cat memory/昨日.md

2. 检查会话类型
   ├── 主会话 → 读取 MEMORY.md
   └── 群组对话 → 不读取 MEMORY.md

3. 环境检查
   ├── pwd
   ├── git status
   └── git log --oneline -10

4. 状态恢复
   ├── 检查未完成工作流
   ├── 读取最近检查点
   └── 确认可继续任务
```

### 任务执行流程

```
1. 任务开始
   └── ./scripts/checkpoint.sh start <task_id>

2. 关键节点
   └── ./scripts/save-state.sh <原因>

3. 每小时同步
   └── ./scripts/sync-hourly.sh

4. 任务完成
   └── ./scripts/checkpoint.sh complete <task_id>
```

### 日终归档流程

```
1. 23:00 触发
   └── ./scripts/archive-daily.sh

2. 生成日报摘要
   └── memory/summary-YYYY-MM-DD.md

3. 更新 MEMORY.md
   └── 追加关键决策和教训

4. 准备明日待办
   └── memory/明日.md
```

## 错误处理

### 常见错误及处理

| 错误 | 原因 | 处理 |
|------|------|------|
| 记忆文件不存在 | 新-project | 自动创建模板文件 |
| 检查点丢失 | 手动删除 | 从 Git 历史恢复 |
| 心跳超时 | 脚本失败 | 手动执行同步 |
| MEMORY.md 锁定 | 文件被占用 | 等待后重试 |

### 错误分级

| 级别 | 类型 | 处理策略 |
|------|------|---------|
| L1 | 文件不存在、超时 | 自动重试/创建 |
| L2 | 同步失败、解析错误 | 通知用户 |
| L3 | 数据损坏、丢失 | 从备份恢复 |

## 配置选项

### 环境变量

```bash
# 目录配置
export MEMORY_DIR="memory"
export CHECKPOINT_DIR="checkpoints"

# 文件配置
export MEMORY_FILE="MEMORY.md"
export STATUS_FILE=".heartbeat-status.json"

# 阈值配置
export CONTEXT_WARNING_THRESHOLD=70
export CONTEXT_SAVE_THRESHOLD=80
export CONTEXT_COMPACT_THRESHOLD=90
```

### Cron 配置

```bash
# Hourly 同步
0 * * * * /path/to/sync-hourly.sh

# Daily 归档
0 23 * * * /path/to/archive-daily.sh

# Weekly 总结
0 22 * * 0 /path/to/summarize-weekly.sh
```

## 最佳实践

### 记忆写入原则

1. **文件就是记忆** - 不要指望"心智笔记"
2. **及时写入** - 关键决策后立即记录
3. **分层管理** - 短期→中期→长期
4. **定期回顾** - Weekly 总结时提炼

### 检查点原则

1. **关键节点保存** - 开始、完成、重要决策后
2. **描述清晰** - 保存原因要具体
3. **Git 联动** - 与 Git 分支/tag 配合
4. **定期清理** - 保留最近 30 天

### 隐私保护

1. **敏感信息分离** - 不写入工作区文件
2. **会话隔离** - MEMORY.md 仅主会话加载
3. **日志脱敏** - 自动过滤敏感信息
4. **Git 排除** - .gitignore 正确配置

## 相关文档

- [长期记忆管理规范](../guidelines/11-LONG_TERM_MEMORY.md)
- [AGENTS.md 模板](../templates/AGENTS.md.template)
- [HEARTBEAT.md 模板](../templates/HEARTBEAT.md.template)
