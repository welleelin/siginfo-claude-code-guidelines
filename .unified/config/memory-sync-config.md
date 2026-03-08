# 长期记忆系统自动同步配置

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：配置三层记忆系统的自动同步机制

---

## 📋 概述

本文档定义长期记忆系统的自动同步配置，确保 Hourly/Daily/Weekly 三层记忆正常运作。

---

## 🔄 同步机制

### Hourly 层（每小时同步）

**触发方式**：手动触发或 cron 任务

**执行脚本**：`./scripts/sync-hourly.sh`

**同步内容**：
- 当前会话的技术决策
- 实时问题解决过程
- 用户偏好的即时捕获
- 临时笔记和待办

**目标文件**：`memory/YYYY-MM-DD.md`

**配置示例**（cron）：
```bash
# 每小时整点执行
0 * * * * cd /path/to/project && ./scripts/sync-hourly.sh >> logs/hourly-sync.log 2>&1
```

### Daily 层（每日 23:00 归档）

**触发方式**：cron 任务

**执行脚本**：`./scripts/archive-daily.sh`

**同步内容**：
- 项目进展和已完成任务
- 重要决策和原因
- 技术债务记录
- 知识沉淀

**目标文件**：
- `memory/YYYY-MM-DD.md`（当日日志）
- `MEMORY.md`（提炼到长期记忆）

**配置示例**（cron）：
```bash
# 每日 23:00 执行
0 23 * * * cd /path/to/project && ./scripts/archive-daily.sh >> logs/daily-archive.log 2>&1
```

### Weekly 层（每周日 22:00 总结）

**触发方式**：cron 任务

**执行脚本**：`./scripts/summarize-weekly.sh`

**同步内容**：
- 核心知识和最佳实践
- 模式识别与复用
- 技术架构决策
- 周度总结

**目标文件**：`MEMORY.md`

**配置示例**（cron）：
```bash
# 每周日 22:00 执行
0 22 * * 0 cd /path/to/project && ./scripts/summarize-weekly.sh >> logs/weekly-summary.log 2>&1
```

---

## 🛠️ 部署步骤

### Step 1: 验证脚本可执行

```bash
# 检查脚本权限
ls -la scripts/*.sh

# 如果没有执行权限，添加
chmod +x scripts/sync-hourly.sh
chmod +x scripts/archive-daily.sh
chmod +x scripts/summarize-weekly.sh
```

### Step 2: 测试脚本执行

```bash
# 测试 Hourly 同步
./scripts/sync-hourly.sh

# 测试 Daily 归档
./scripts/archive-daily.sh

# 测试 Weekly 总结
./scripts/summarize-weekly.sh
```

### Step 3: 配置 cron 任务（可选）

```bash
# 编辑 crontab
crontab -e

# 添加以下内容（替换 /path/to/project 为实际路径）
# Hourly 同步（每小时整点）
0 * * * * cd /path/to/project && ./scripts/sync-hourly.sh >> logs/hourly-sync.log 2>&1

# Daily 归档（每日 23:00）
0 23 * * * cd /path/to/project && ./scripts/archive-daily.sh >> logs/daily-archive.log 2>&1

# Weekly 总结（每周日 22:00）
0 22 * * 0 cd /path/to/project && ./scripts/summarize-weekly.sh >> logs/weekly-summary.log 2>&1

# 保存并退出
```

### Step 4: 创建日志目录

```bash
# 创建日志目录
mkdir -p logs

# 添加到 .gitignore
echo "logs/" >> .gitignore
```

### Step 5: 验证 cron 任务

```bash
# 查看 cron 任务列表
crontab -l

# 查看 cron 日志（macOS）
tail -f /var/log/system.log | grep cron

# 查看 cron 日志（Linux）
tail -f /var/log/syslog | grep CRON
```

---

## 🔧 手动同步方式

如果不使用 cron 任务，可以手动执行同步：

### 手动 Hourly 同步

```bash
# 在会话中执行
./scripts/sync-hourly.sh
```

**建议频率**：每小时一次，或在关键决策后立即执行

### 手动 Daily 归档

```bash
# 每日结束前执行
./scripts/archive-daily.sh
```

**建议时间**：每日 23:00 或工作结束前

### 手动 Weekly 总结

```bash
# 每周结束时执行
./scripts/summarize-weekly.sh
```

**建议时间**：每周日晚上或周一早上

---

## 📊 监控与验证

### 检查同步状态

```bash
# 查看最近的 Hourly 同步
ls -lt memory/*.md | head -5

# 查看 Daily 归档记录
grep "## 📊 项目里程碑" MEMORY.md

# 查看 Weekly 总结
grep "## 🌐 互联网调研最佳实践" MEMORY.md
```

### 检查日志文件

```bash
# 查看 Hourly 同步日志
tail -20 logs/hourly-sync.log

# 查看 Daily 归档日志
tail -20 logs/daily-archive.log

# 查看 Weekly 总结日志
tail -20 logs/weekly-summary.log
```

### 验证记忆文件完整性

```bash
# 检查 memory 目录
ls -la memory/

# 检查 MEMORY.md 大小
wc -l MEMORY.md

# 检查 checkpoints 目录
ls -la checkpoints/
```

---

## 🔐 安全与隐私

### 敏感信息处理

**禁止写入记忆文件**：
- API Key、密码、Token
- 服务器 IP 地址（使用占位符）
- 个人联系方式
- 数据库连接字符串

**正确做法**：
```markdown
# ❌ 错误
API_KEY: sk-1234567890abcdef

# ✅ 正确
API_KEY: 存在于环境变量 PROJECT_API_KEY
```

### Git 备份配置

```gitignore
# .gitignore 推荐配置
logs/
.DS_Store
.key
.pem
.secrets/
*.local
```

---

## 📝 配置验证清单

### 部署前检查

- [ ] 脚本有执行权限
- [ ] 脚本可以正常运行
- [ ] memory/ 目录存在
- [ ] checkpoints/ 目录存在
- [ ] logs/ 目录存在
- [ ] .gitignore 已配置

### 部署后检查

- [ ] cron 任务已配置（如使用）
- [ ] Hourly 同步正常工作
- [ ] Daily 归档正常工作
- [ ] Weekly 总结正常工作
- [ ] 日志文件正常生成
- [ ] 记忆文件正常更新

---

## 🔗 相关文档

- [长期记忆管理规范](../../guidelines/11-LONG_TERM_MEMORY.md)
- [系统总则](../../guidelines/00-SYSTEM_OVERVIEW.md)
- [脚本使用文档](../../scripts/README.md)

---

*版本：1.0.0 | 创建日期：2026-03-08*
