# Agent-Reach 集成指南

> **版本**：1.0.0
> **整合日期**：2026-03-05
> **来源**：https://github.com/Panniantong/Agent-Reach

---

## 📋 概述

Agent-Reach 是一个为 AI Agent 提供互联网访问能力的脚手架工具，支持 13+ 平台的无缝集成。

### 核心价值

| 特性 | 说明 |
|------|------|
| 💰 **完全免费** | 所有工具开源、所有 API 免费，唯一可能花钱的是服务器代理（$1/月） |
| 🔒 **隐私安全** | Cookie 本地存储，不上传不外传，代码完全开源 |
| 🔄 **持续更新** | 底层工具定期追踪更新，无需手动维护 |
| 🤖 **兼容所有 Agent** | Claude Code、OpenClaw、Cursor、Windsurf 等 |
| 🩺 **自带诊断** | `agent-reach doctor` 一键检测所有渠道状态 |

---

## 🏗️ 架构设计

### 与长期记忆系统的集成架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent-Reach + Memory 集成架构              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   Agent-Reach   │    │  长期记忆系统    │                 │
│  │   (互联网能力)   │◄──┤  (状态持久化)    │                 │
│  └─────────────────┘    └─────────────────┘                 │
│         │                      │                            │
│         │                      │                            │
│         ▼                      ▼                            │
│  ┌─────────────────────────────────────────┐                │
│  │           上游工具层                     │                │
│  ├─────────────────────────────────────────┤                │
│  │  Jina Reader  │  yt-dlp  │  xreach      │                │
│  │  gh CLI       │  mcporter │  feedparser │                │
│  └─────────────────────────────────────────┘                │
│                                                             │
│  ┌─────────────────────────────────────────┐                │
│  │           平台渠道层                     │                │
│  ├─────────────────────────────────────────┤                │
│  │  Twitter │  YouTube │  GitHub │ 小红书  │                │
│  │  B 站     │  Reddit  │  抖音   │ LinkedIn│                │
│  │  Boss 直聘│  微信    │   RSS   │ 全网搜索│               │
│  └─────────────────────────────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 集成点

| 集成点 | 说明 | 实现方式 |
|--------|------|---------|
| **搜索结果持久化** | 将 Agent-Reach 搜索结果写入记忆 | Hourly 层记录 |
| **重要决策归档** | 互联网调研支持的关键决策 | Daily 层归档 |
| **知识提炼** | 从互联网内容提炼最佳实践 | Weekly 层总结 |
| **Cookie/凭据管理** | 安全存储平台凭据 | 凭据分离存储 |
| **任务上下文恢复** | 保存 Agent-Reach 任务状态 | 检查点管理 |

---

## 📦 安装与配置

### 一键安装

```bash
# 复制给你的 AI Agent
帮我安装 Agent Reach：https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/install.md
```

### 手动安装

```bash
# 1. 安装 Python 包
pip install agent-reach

# 2. 运行安装
agent-reach install

# 3. 检测状态
agent-reach doctor
```

### 安全模式（推荐生产环境）

```bash
# 只预览需要什么，不自动安装
agent-reach install --safe

# 或仅预览操作
agent-reach install --dry-run
```

### 卸载

```bash
# 完全卸载
agent-reach uninstall

# 保留配置（方便重装）
agent-reach uninstall --keep-config

# 仅预览删除
agent-reach uninstall --dry-run
```

---

## 🔌 支持的平台

### 无需配置即用

| 平台 | 功能 | 命令示例 |
|------|------|---------|
| 🌐 **网页** | 阅读任意网页 | `curl https://r.jina.ai/URL` |
| 📺 **YouTube** | 字幕提取 + 视频搜索 | `yt-dlp --dump-json URL` |
| 📡 **RSS** | 阅读任意 RSS/Atom 源 | `feedparser` |
| 📦 **GitHub** | 读公开仓库 + 搜索 | `gh repo view owner/repo` |

### 需要配置

| 平台 | 配置方式 | 解锁功能 |
|------|---------|---------|
| 🐦 **Twitter/X** | Cookie-Editor 导出 Cookie | 搜索推文、浏览时间线、发推 |
| 📺 **B 站** | 配置住宅代理（服务器） | 字幕提取、视频搜索 |
| 📖 **Reddit** | 配置住宅代理 | 读帖子和评论 |
| 📕 **小红书** | Docker 运行 MCP 服务 | 阅读、搜索、发帖、评论、点赞 |
| 🎵 **抖音** | 安装 MCP 服务 | 视频解析、无水印下载 |
| 💼 **LinkedIn** | 配置 MCP 服务 | Profile 详情、公司页面、职位搜索 |
| 🏢 **Boss 直聘** | 配置 MCP 服务 | 搜索职位、向 HR 打招呼 |
| 💬 **微信公众号** | `pip install miku_ai camoufox` | 搜索 + 阅读公众号文章 |
| 🔍 **全网搜索** | 自动配置（MCP 接入 Exa） | AI 语义搜索 |

### Cookie 配置流程

> ⚠️ **封号风险提醒：** 使用 Cookie 登录的平台（Twitter、小红书等），建议使用**专用小号**，不要用主账号。

```bash
# 1. 浏览器登录目标平台
# 2. 使用 Cookie-Editor 插件导出 Cookie
# 3. 配置到 Agent-Reach
agent-reach configure twitter-cookies "your_cookies_string"

# 4. 验证配置
agent-reach doctor
```

---

## 🔧 与记忆系统集成

### 记忆文件布局

```
project/
├── MEMORY.md                          # 长期记忆（Weekly 层）
│   ├── 🌐 互联网调研最佳实践
│   ├── 📊 平台渠道配置记录
│   └── 📝 重要调研发现归档
├── memory/
│   ├── 2026-03-05.md                  # 每日日志（Hourly/Daily 层）
│   │   ├── 🕐 [Hourly] Agent-Reach 搜索结果
│   │   ├── 💡 技术决策（基于互联网调研）
│   │   └── 🔗 相关链接和引用
│   └── archive/                       # 历史归档
└── .agent-reach/                      # Agent-Reach 配置
    └── config.yaml                    # Cookie/凭据（Git 忽略）
```

### Git 忽略配置

```gitignore
# .gitignore
.agent-reach/               # Cookie/凭据
.agent-reach/config.yaml    # 敏感配置
```

---

## 📝 使用场景

### 场景 1：技术调研

```bash
# 1. 搜索 GitHub 相关项目
gh search repos "LLM framework" --language=python

# 2. 记录搜索结果到记忆
./scripts/sync-hourly.sh

# 3. 关键发现写入 MEMORY.md
# 在 Weekly 层记录最佳实践
```

### 场景 2：社交媒体监控

```bash
# 1. 搜索 Twitter 讨论
xreach search "产品名" --json

# 2. 提取热门推文内容
xreach tweet "推文 URL" --json

# 3. 记录到 Hourly 层
# memory/今日.md - Hourly 实时记录
```

### 场景 3：视频内容分析

```bash
# 1. 提取 YouTube 字幕
yt-dlp --dump-json "https://youtube.com/watch?v=xxx"

# 2. 下载字幕文件
yt-dlp --write-sub --skip-download "URL"

# 3. 总结到 Daily 层
# memory/今日.md - 技术决策/问题解决
```

### 场景 4：RSS 订阅追踪

```python
# 1. 使用 feedparser 读取 RSS
import feedparser
feed = feedparser.parse("https://example.com/rss")

# 2. 记录新内容到记忆
# 更新 memory/今日.md - 待办事项
```

---

## 🛠️ 脚本集成

### 增强的 init-memory.sh

在初始化记忆系统时，同时检测 Agent-Reach：

```bash
# 添加到 init-memory.sh
check_agent_reach() {
    if command -v agent-reach &> /dev/null; then
        success "Agent-Reach 已安装"
        agent-reach doctor
    else
        warning "Agent-Reach 未安装"
        echo "安装命令："
        echo "  pip install agent-reach"
        echo "  agent-reach install"
    fi
}
```

### 记忆搜索增强

在 `commands/memory-search.md` 中添加 Agent-Reach 能力：

```bash
# 互联网实时搜索
/agent-reach-search "<查询>"

# 示例:
# /agent-reach-search "最新 LLM 框架对比"
# /agent-reach-search-twitter "产品评价"
# /agent-reach-search-github "awesome AI"
```

---

## 📊 记忆写入规范

### Hourly 层（实时记录）

```markdown
## 🕐 Hourly 层 - 实时记录

### [10:00] Agent-Reach 调研

**查询**: "最新 React 状态管理方案"

**来源**:
- GitHub: gh search repos "react state management 2026"
- Twitter: xreach search "react state management"

**发现**:
1. Zustand 持续增长（GitHub ⭐50K+）
2. Jotai v2 性能提升显著
3. 社区推荐：小项目 Zustand，大项目 Redux Toolkit

**相关链接**:
- https://github.com/pmndrs/zustand
- https://twitter.com/...
```

### Daily 层（每日归档）

```markdown
## 💡 技术决策

**日期**: 2026-03-05
**决策**: 选择 Zustand 作为项目状态管理方案

**调研依据** (via Agent-Reach):
- GitHub 趋势榜：Zustand 周增长 +2K ⭐
- Twitter 讨论：开发者满意度 92%
- 技术博客对比：https://...

** MEMORY.md 更新**:
- 记录到 "状态管理最佳实践" 章节
```

### Weekly 层（周度总结）

```markdown
## 🌐 互联网调研最佳实践

### 工具选型调研流程

1. **GitHub 搜索** (`gh search repos`)
   - 按 stars 排序，查看近期增长
   - 检查 Issue 活跃度

2. **Twitter/X 舆论** (`xreach search`)
   - 开发者真实反馈
   - 避坑指南

3. **YouTube 教程** (`yt-dlp`)
   - 官方教程字幕提取
   - 实战案例总结

4. **RSS 订阅追踪** (`feedparser`)
   - 技术博客更新
   - 官方公告

### 各平台最佳实践

| 平台 | 用途 | 记录方式 |
|------|------|---------|
| GitHub | 工具选型 | MEMORY.md - 技术栈 |
| Twitter | 舆论监控 | memory/ 日志 - 实时记录 |
| YouTube | 学习资源 | memory/ 日志 - 教程摘要 |
| RSS | 信息追踪 | MEMORY.md - 订阅源列表 |
```

---

## 🔐 安全与隐私

### Cookie 管理

```yaml
# ~/.agent-reach/config.yaml
# 权限：chmod 600 (仅所有者可读写)

twitter:
  cookies: "..."  # 本地存储，不上传
xiaohongshu:
  cookies: "..."
```

### 记忆文件安全

| 文件类型 | 是否提交 Git | 说明 |
|---------|-------------|------|
| `MEMORY.md` | ✅ 是 | 不包含敏感信息 |
| `memory/*.md` | ✅ 是 | 脱敏后提交 |
| `.agent-reach/config.yaml` | ❌ 否 | 包含 Cookie |
| `.env` | ❌ 否 | 环境变量/密钥 |

### 凭据分离存储

```bash
# 正确做法：敏感信息分离
# 记忆文件中
数据库：PostgreSQL (版本 15)
缓存：Redis (使用 AWS ElastiCache)

# 凭据存储在 ~/.openclaw/credentials/
database_url: "postgresql://user:pass@host:5432/db"
redis_url: "redis://user:pass@host:6379"
```

---

## 🧪 诊断与调试

### Agent-Reach 诊断

```bash
# 检测所有渠道状态
agent-reach doctor

# 输出示例:
# ✅ Web (Jina Reader)
# ✅ YouTube (yt-dlp)
# ⚠️  Twitter (需要配置 Cookie)
# ❌  Reddit (需要代理)
```

### 记忆系统诊断

```bash
# 检查记忆文件
./scripts/checkpoint.sh status

# 检查心跳状态
cat .heartbeat-status.json | jq
```

### 联合诊断脚本

```bash
#!/bin/bash
# scripts/diagnose.sh

echo "═══════════════════════════════════════"
echo "        Agent-Reach + Memory 诊断       "
echo "═══════════════════════════════════════"

echo ""
echo "📦 Agent-Reach 状态:"
agent-reach doctor

echo ""
echo "🧠 Memory 系统状态:"
./scripts/checkpoint.sh status

echo ""
echo "📁 记忆文件:"
ls -la memory/
ls -la checkpoints/
```

---

## 📈 效能指标

| 指标 | 目标值 | 测量方式 |
|------|--------|---------|
| 调研效率提升 | 5x | 对比手动搜索时间 |
| 信息覆盖率 | 90%+ | 多渠道覆盖度 |
| 决策质量 | 85%+ | 事后验证准确率 |
| 记忆检索召回率 | 90%+ | 历史调研复用率 |

---

## 🚀 最佳实践

### 1. 调研前准备

```bash
# 1. 检查渠道状态
agent-reach doctor

# 2. 开始任务检查点
./scripts/checkpoint.sh start <task_id>

# 3. 记录调研目标
echo "调研目标：..." >> memory/今日.md
```

### 2. 调研中记录

```bash
# 每 30 分钟同步一次
./scripts/sync-hourly.sh

# 关键发现立即记录
echo "## 关键发现\n\n1. ..." >> memory/今日.md
```

### 3. 调研后归档

```bash
# 1. 总结到 Daily 层
./scripts/archive-daily.sh

# 2. 提炼到 Weekly 层
./scripts/summarize-weekly.sh

# 3. 更新 MEMORY.md
# - 最佳实践
# - 工具选型
# - 经验教训
```

---

## 🔗 相关文档

- [长期记忆管理规范](11-LONG_TERM_MEMORY.md)
- [记忆管理 Agent](../agents/memory-keeper.md)
- [Agent-Reach GitHub](https://github.com/Panniantong/Agent-Reach)
- [OpenClaw Memory 最佳实践](https://chenguangliang.com/posts/openclaw-memory-best-practices/)

---

*版本：1.0.0*
*最后更新：2026-03-05*
