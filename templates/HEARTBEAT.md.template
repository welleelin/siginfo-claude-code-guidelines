# Heartbeat 定期检查任务

> 配置 Agent 定期执行的例行检查任务
>
> 更新频率：根据需要调整
> 最后更新：{DATE}

---

## 🕐 每小时检查 (Every Hour)

### 检查项目
- [ ] 检查工作流状态
- [ ] 同步 Hourly 层记忆
- [ ] 检查是否有待确认事项
- [ ] 检查上下文使用率

### 执行脚本
```bash
./scripts/sync-hourly.sh
```

### 状态回复
- 如有具体任务需要注意 → 发送消息提醒
- 如无事项 → 回复 `HEARTBEAT_OK`（静默）

---

## 📅 每日检查 (Daily - 23:00)

### 检查项目
- [ ] 检查今日任务完成情况
- [ ] 整理今日技术决策
- [ ] 归档日志到 memory/
- [ ] 准备明日待办清单
- [ ] 检查 Git 提交状态

### 执行脚本
```bash
./scripts/archive-daily.sh
```

### 日报模板
```markdown
## {DATE} 日报

### 完成
- {task_1}
- {task_2}

### 进行中
- {task_3} ({progress}%)

### 问题
- {issue}

### 明日计划
- {plan_1}
- {plan_2}
```

---

## 📆 每周检查 (Weekly - 周日 22:00)

### 检查项目
- [ ] 读取过去 7 天的 memory/YYYY-MM-DD.md
- [ ] 提取重要决策和教训
- [ ] 更新 MEMORY.md 中的相关章节
- [ ] 清理 MEMORY.md 中过时的信息
- [ ] 生成周度总结报告

### 执行脚本
```bash
./scripts/summarize-weekly.sh
```

### 周报模板
```markdown
## 周度总结 ({WEEK_NUMBER})

### 里程碑进展
| 里程碑 | 本周进展 | 累计进度 |
|--------|---------|---------|
| {milestone} | {progress} | {total}% |

### 关键决策
- {decision_1}
- {decision_2}

### 经验教训
- {lesson_1}
- {lesson_2}

### 下周计划
- {plan_1}
- {plan_2}
```

---

## 🌙 每月检查 (Monthly - 月末)

### 检查项目
- [ ] 月度项目状态审查
- [ ] 技术债务评估
- [ ] 性能指标分析
- [ ] 下月目标规划

### 执行脚本
```bash
./scripts/summarize-monthly.sh
```

---

## 🔔 特殊检查点

### 部署前检查
- [ ] 代码已审查
- [ ] 测试已覆盖
- [ ] 备份已完成
- [ ] 回滚方案已准备

### 发布后验证
- [ ] 服务可访问
- [ ] 关键功能正常
- [ ] 监控指标正常
- [ ] 用户反馈收集

---

## 📊 检查状态记录

### 最后检查时间
| 检查类型 | 最后执行时间 | 状态 |
|---------|------------|------|
| Hourly | {LAST_HOURLY} | {HOURLY_STATUS} |
| Daily | {LAST_DAILY} | {DAILY_STATUS} |
| Weekly | {LAST_WEEKLY} | {WEEKLY_STATUS} |

### 状态文件
维护 `.heartbeat-status.json` 记录检查状态：
```json
{
  "hourly": {
    "lastCheck": "2026-03-04T15:00:00+08:00",
    "status": "ok"
  },
  "daily": {
    "lastCheck": "2026-03-03T23:00:00+08:00",
    "status": "ok"
  },
  "weekly": {
    "lastCheck": "2026-03-02T22:00:00+08:00",
    "status": "ok"
  }
}
```

---

## ⚙️ 配置说明

### 自定义检查频率

在配置文件中修改：
```json
{
  "heartbeat": {
    "hourly": { "enabled": true, "interval": 3600000 },
    "daily": { "enabled": true, "time": "23:00" },
    "weekly": { "enabled": true, "day": "sunday", "time": "22:00" }
  }
}
```

### 添加自定义检查

在对应时间段添加检查项：
```markdown
## 自定义检查项

### 博客 Agent
- [ ] 检查网站可访问性
- [ ] 检查 GitHub 仓库同步状态
- [ ] 生成技术博客内容提案

### 监控 Agent
- [ ] 监控技术趋势（HN、Reddit）
- [ ] 记录有价值的技术话题
```

---

> **Heartbeat 原则**：
> 1. 定期检查，避免遗忘
> 2. 无事静默，有事提醒
> 3. 状态可追溯，支持断点恢复
> 4. 灵活配置，按需调整
