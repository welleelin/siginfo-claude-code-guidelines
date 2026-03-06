# 记忆日志 - {DATE}

> 日期：{DATE}
> 会话数：{SESSION_COUNT}
> 状态：{STATUS}

---

## 📋 今日任务

| 任务 ID | 任务标题 | 状态 | 进度 | 备注 |
|--------|---------|------|------|------|
| {TASK_ID} | {TITLE} | {STATUS} | {PROGRESS}% | {NOTE} |

---

##  Hourly 层 - 实时记录

> 每小时同步一次，记录当前会话的技术决策和实时问题。

### {HH:00} - {主题}
- **类型**：{type: technical|decision|problem|preference}
- **内容**：
  {content}
- **标签**：{tags}

---

## 💡 技术决策

### {决策标题}
- **时间**：{TIME}
- **背景**：{context}
- **选项**：
  1. {option_1}
  2. {option_2}
- **决定**：{decision}
- **原因**：{reason}
- **影响**：{impact}

---

## 🐛 问题解决

### {问题标题}
- **时间**：{TIME}
- **现象**：{symptom}
- **排查过程**：
  1. {step_1}
  2. {step_2}
- **根本原因**：{root_cause}
- **解决方案**：{solution}
- **预防措施**：{prevention}

---

## 📝 临时笔记

> 当日临时记录，可能不需要长期保留。

- {note_1}
- {note_2}

---

## ✅ 今日完成

- [x] {task_1}
- [x] {task_2}
- [x] {task_3}

---

## 🔄 待办事项

- [ ] {todo_1} - 优先级：{priority}
- [ ] {todo_2} - 优先级：{priority}

---

## 📊 会话摘要

| 会话 ID | 开始时间 | 结束时间 | 主要活动 | 关键产出 |
|--------|---------|---------|---------|---------|
| {session_id} | {start} | {end} | {activity} | {output} |

---

## 🌟 今日亮点

> 记录今日的重要进展或突破。

{highlights}

---

## 🔗 相关文件

- 修改文件：{modified_files}
- 新增文件：{created_files}
- 删除文件：{deleted_files}

---

> **日终归档提醒**：
> - [ ] 检查所有任务状态是否已更新
> - [ ] 确认关键决策已记录
> - [ ] 清理临时笔记
> - [ ] 准备明日待办
> - [ ] 23:00 执行 `./scripts/archive-daily.sh` 归档
