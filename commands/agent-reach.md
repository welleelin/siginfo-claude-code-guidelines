# /agent-reach - Agent-Reach 互联网访问能力

> **版本**：1.0.0
> **基于**：Agent-Reach v1.0 (https://github.com/Panniantong/Agent-Reach)

---

## 功能描述

为 AI Agent 提供互联网访问能力，支持 13+ 平台的无缝集成。

---

## 支持的平台

| 平台 | 装好即用 | 配置后解锁 | 命令示例 |
|------|---------|-----------|---------|
| 🌐 **网页** | ✅ 阅读任意网页 | — | `curl https://r.jina.ai/URL` |
| 📺 **YouTube** | ✅ 字幕提取 + 搜索 | — | `yt-dlp --dump-json URL` |
| 📡 **RSS** | ✅ 阅读 RSS/Atom | — | `feedparser` |
| 🔍 **全网搜索** | — | ✅ AI 语义搜索 | `exa search "..."` |
| 📦 **GitHub** | ✅ 读公开仓库 | ✅ 私有仓库/提 Issue | `gh repo view` |
| 🐦 **Twitter/X** | ✅ 读单条推文 | ✅ 搜索/时间线/发推 | `xreach search` |
| 📺 **B 站** | ✅ 本地字幕提取 | ✅ 服务器可用 | 需代理 |
| 📖 **Reddit** | ✅ 搜索（Exa） | ✅ 读帖子和评论 | 需代理 |
| 📕 **小红书** | — | ✅ 阅读/搜索/互动 | Docker MCP |
| 🎵 **抖音** | — | ✅ 视频解析/无水印 | MCP 服务 |
| 💼 **LinkedIn** | ✅ 读公开页面 | ✅ Profile/公司/职位 | MCP 服务 |
| 🏢 **Boss 直聘** | ✅ 读职位页 | ✅ 搜索/打招呼 | MCP 服务 |
| 💬 **微信公众号** | — | ✅ 搜索 + 阅读全文 | `miku_ai` |

---

## 命令定义

### /agent-reach-install

安装 Agent-Reach：

```bash
# 完整安装（默认）
/agent-reach-install

# 安全模式（只预览，不自动安装）
/agent-reach-install --safe

# 仅预览操作
/agent-reach-install --dry-run
```

### /agent-reach-doctor

检测所有渠道状态：

```bash
/agent-reach-doctor
```

**输出示例**：
```
═══════════════════════════════════════
        Agent-Reach 渠道状态
═══════════════════════════════════════

✅ Web (Jina Reader)
✅ YouTube (yt-dlp)
✅ GitHub (gh CLI)
⚠️  Twitter (需要配置 Cookie)
⚠️  Reddit (需要代理)
❌ 小红书 (需要 Docker)

配置建议:
- Twitter: 使用 Cookie-Editor 导出 Cookie
- Reddit: 配置住宅代理 (Webshare $1/月)
- 小红书：安装 Docker 并运行 MCP 服务
```

### /agent-reach-configure

配置特定渠道：

```bash
# 配置 Twitter Cookie
/agent-reach-configure twitter-cookies "YOUR_COOKIE_STRING"

# 配置代理
/agent-reach-configure proxy "http://user:pass@ip:port"

# 配置 GitHub Token
/agent-reach-configure github-token "ghp_..."
```

### /agent-reach-search

全网搜索：

```bash
# 全网语义搜索
/agent-reach-search "<查询词>"

# 指定平台搜索
/agent-reach-search-github "<查询>"
/agent-reach-search-twitter "<查询>"
/agent-reach-search-youtube "<查询>"
/agent-reach-search-reddit "<查询>"
```

### /research-start

开始互联网调研：

```bash
/research-start "<主题>"

# 示例:
/research-start "React 状态管理方案对比"
/research-start "最新 LLM 框架评测"
/research-start "Twitter 上大家对产品 A 的评价"
```

**执行流程**：
1. 检查渠道状态 (`agent-reach doctor`)
2. 开始任务检查点 (`checkpoint.sh start`)
3. 选择合适渠道
4. 执行搜索
5. 记录结果到 memory/今日.md

### /research-save

保存调研中间结果：

```bash
/research-save "<关键发现>"

# 示例:
/research-save "Zustand: GitHub ⭐50K+, 周增长 +2K, Twitter 推荐度 92%"
```

### /research-complete

完成调研并归档：

```bash
/research-complete
```

**自动执行**：
1. 生成调研摘要
2. 更新 MEMORY.md（最佳实践章节）
3. 清理临时笔记
4. 完成任务检查点

---

## 使用场景

### 场景 1：技术选型调研

```bash
# 1. 开始调研
/research-start "React 状态管理方案"

# 2. GitHub 搜索
gh search repos "react state management" --sort=stars

# 3. Twitter 舆论
xreach search "react state management recommendation"

# 4. YouTube 教程
yt-dlp --dump-json "https://youtube.com/watch?v=..."

# 5. 保存发现
/research-save "社区推荐：小项目 Zustand, 大项目 Redux Toolkit"

# 6. 完成归档
/research-complete
```

### 场景 2：社交媒体监控

```bash
# 搜索产品讨论
xreach search "产品名 评测" --json

# 提取热门推文
xreach tweet "推文 URL" --json

# 记录到记忆
echo "## Twitter 舆论监控\n\n正面评价 78%..." >> memory/今日.md
```

### 场景 3：视频内容分析

```bash
# 提取 YouTube 字幕
yt-dlp --write-sub --skip-download "URL"

# 查看字幕内容
cat "*.vtt"

# 总结到记忆
echo "## 视频教程摘要\n\n1. ..." >> memory/今日.md
```

### 场景 4：GitHub 项目分析

```bash
# 查看项目详情
gh repo view owner/repo

# 查看 Issue
gh issue list --repo owner/repo

# 查看趋势
gh search repos "awesome AI" --sort=updated
```

---

## 配置流程

### Twitter Cookie 配置

```bash
# 1. 浏览器登录 twitter.com
# 2. 安装 Cookie-Editor 插件 (Chrome/Firefox)
# 3. 点击插件，导出 Cookie 为字符串
# 4. 配置到 Agent-Reach

/agent-reach-configure twitter-cookies "cookie_string_here"

# 5. 验证
agent-reach doctor
```

### 代理配置（Reddit/B 站）

```bash
# 1. 购买住宅代理 (推荐 Webshare, $1/月)
# 2. 获取代理信息

/agent-reach-configure proxy "http://user:pass@ip:port"

# 3. 验证
curl --proxy "http://user:pass@ip:port" https://www.reddit.com
```

### 小红书 MCP 配置

```bash
# 1. 安装 Docker
# 2. 运行 MCP 服务

docker run -d \
  -p 8765:8765 \
  -e XHS_PHONE="手机号" \
  -e XHS_COOKIE="Cookie" \
  ghcr.io/xpzouying/xiaohongshu-mcp:latest

# 3. 验证
mcporter call 'xiaohongshu.get_feed_detail(note_id: "xxx")'
```

---

## 安全与隐私

### Cookie 安全

| 措施 | 说明 |
|------|------|
| 🔒 **本地存储** | Cookie 只存在 `~/.agent-reach/config.yaml`，权限 600 |
| 🛡️ **专用小号** | 使用专用小号，避免主账号被封 |
| 👀 **定期更换** | 建议每月更换一次 Cookie |
| 🚫 **不上传** | Cookie 不上传任何服务器 |

### 记忆文件安全

| 文件 | 是否提交 Git | 说明 |
|------|-------------|------|
| `MEMORY.md` | ✅ 是 | 不包含敏感信息 |
| `memory/*.md` | ✅ 是 | 脱敏后提交 |
| `~/.agent-reach/config.yaml` | ❌ 否 | 包含 Cookie |

---

## 错误处理

| 错误 | 原因 | 处理 |
|------|------|------|
| Cookie 过期 | Twitter/XHS 登录失效 | 重新导出 Cookie |
| 403 Forbidden | Reddit/B 站 IP 被封 | 配置代理 |
| 服务不可用 | Docker 未运行 | `docker start` |
| 搜索无结果 | 关键词问题 | 优化查询词 |

---

## 相关文档

- [Agent-Reach 集成指南](../guidelines/12-AGENT_REACH_INTEGRATION.md)
- [Agent-Reach GitHub](https://github.com/Panniantong/Agent-Reach)
- [长期记忆管理规范](../guidelines/11-LONG_TERM_MEMORY.md)
- [Agent 行为规范](../templates/AGENTS.md.template)

---

*版本：1.0.0*
*最后更新：2026-03-05*
