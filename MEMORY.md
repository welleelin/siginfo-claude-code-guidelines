# 项目记忆 - sig-claude-code-guidelines

> 最后更新：2026-03-07T15:00:00+08:00
> 会话 ID: session-20260307-001
> 项目状态：活跃开发中

---

## 🚨 持久化约束 (Compact 后必须保留)

> **重要**：以下内容在上下文压缩 (compact) 后必须保留，是项目的核心记忆。

### 当前任务状态

| 字段 | 值 |
|------|-----|
| **任务 ID** | - |
| **任务标题** | 系统初始化完成，等待新任务 |
| **当前阶段** | idle |
| **当前步骤** | - |
| **进度** | - |

### 测试模式约束

| 测试阶段 | 允许 Mock | 当前状态 | 完成时间 |
|---------|----------|---------|---------|
| 前端开发 | ✅ 是 | - | - |
| 前端 Mock 测试 | ✅ 是 | - | - |
| 后端 API 测试 | ❌ 否 | - | - |
| 前后端联调 | ❌ 否 | - | - |
| E2E 测试 | ❌ 否 | - | - |

### Mock 接口登记

| 接口 | Mock 原因 | 标记位置 | 预计替换时间 |
|------|----------|---------|-------------|
| - | - | - | - |

---

## 📋 关键决策记录

| 时间 | 决策 | 原因 | 影响范围 |
|------|------|------|---------|
| 2026-03-07 | 使用现有工具实现互联网访问 | Agent-Reach 安装受阻，但已有足够工具 | 技术调研流程 |
| 2026-03-06 | 使用 perl 替代 sed 处理模板替换 | macOS sed 兼容性问题 | init-memory.sh |

---

## 🎯 用户偏好与规范

### 技术偏好
- 编程语言：Shell/Bash, TypeScript
- 框架选择：无特定框架（规范文档项目）
- 代码风格：简洁、可维护

### 沟通风格
- 详细程度：简洁
- 通知渠道：控制台输出
- 确认频率：关键决策时确认

### 工作时间
- 工作时段：日常工作时间
- 响应期望：实时响应

---

## 📊 项目里程碑

| 里程碑 | 状态 | 完成时间 | 备注 |
|--------|------|---------|------|
| 文档完整性 Phase 2 | 🔄 进行中 | 2026-03-07 | 已达到 75%，发现 guidelines 缺失 |
| 文档完整性 Phase 1 | ✅ 完成 | 2026-03-07 | 达到 60% 完整度 |
| 互联网访问工具配置 | ✅ 完成 | 2026-03-07 | gh CLI 完全可用，yt-dlp 已安装 |
| 项目初始化 | ✅ 完成 | 2026-03-06 | 记忆系统已就绪 |
| Chrome DevTools MCP 集成 | ✅ 完成 | 2026-03-05 | 深度测试能力 |
| 大模型渠道切换 | ✅ 完成 | 2026-03-04 | 多模型支持 |

---

## ⚠️ 经验教训

### 2026-03-07 - 文档完整性评估与改进

- **问题**：初始评估文档完整度为 90%，实际仅 30%
- **原因**：未仔细检查所有文档，遗漏了多个关键文档
- **解决方案**：制定三阶段行动计划，逐步提升到 100%
- **预防措施**：建立文档完整性检查清单，定期审查

**Phase 1 完成情况**（目标 60%）：
- ✅ 创建 docs/GITHUB_CLI_GUIDE.md（400+ 行）
- ✅ 创建 scripts/README.md（430+ 行）
- ✅ 更新 README.md 添加互联网访问工具章节
- ✅ 更新 HEARTBEAT.md 添加工具检查任务

**下一步**：Phase 2（目标 80%）
- 创建技术调研模板
- 创建自动化脚本示例文档
- 检查 guidelines 01-07 文档完整性
- 创建 commands 使用文档

### 2026-03-07 - Agent-Reach 安装问题
- **问题**：agent-reach 包不存在于 PyPI，GitHub 连接超时
- **原因**：Agent-Reach 可能需要从源码安装，网络代理配置问题
- **解决方案**：使用现有工具（gh CLI + yt-dlp）实现互联网访问
- **预防措施**：优先使用成熟稳定的工具，避免依赖单一工具集

### 2026-03-07 - YouTube 访问速度慢
- **问题**：yt-dlp 访问 YouTube 超时（>30 秒）
- **原因**：网络连接慢或 YouTube 访问受限
- **解决方案**：优先使用 GitHub CLI 进行技术调研，YouTube 仅在必要时使用
- **预防措施**：配置网络代理，或使用其他视频平台

### 2026-03-06 - macOS sed 兼容性问题
- **问题**：init-memory.sh 中 sed 命令在 macOS 上报错
- **原因**：macOS sed 与 GNU sed 语法差异
- **解决方案**：使用 perl -pe 替代 sed 进行模板变量替换
- **预防措施**：跨平台脚本优先使用 perl 或 python

---

## 🔗 相关资源

### 项目链接
- 项目仓库：https://github.com/your-org/sig-claude-code-guidelines
- 本地路径：/Users/cloud/Documents/projects/Claude/sig-claude-code-guidelines

### 互联网访问工具
- GitHub CLI 文档：https://cli.github.com/manual/
- yt-dlp 文档：https://github.com/yt-dlp/yt-dlp
- Agent-Reach 仓库：https://github.com/Panniantong/Agent-Reach

### 已配置工具

| 工具 | 版本 | 状态 | 用途 |
|------|------|------|------|
| gh | 2.86.0 | ✅ 可用 | GitHub 仓库/代码搜索 |
| yt-dlp | 2025.04.30 | ⚠️ 慢 | YouTube 字幕提取、视频信息 |
| curl | 8.7.1 | ✅ 可用 | HTTP 请求 |
| jq | 1.7.1 | ✅ 可用 | JSON 处理 |
| pipx | 1.7.1 | ✅ 可用 | Python 应用管理 |

---

## 🌐 互联网访问最佳实践

### GitHub 调研流程（推荐）✅

#### 1. 搜索相关项目
```bash
# 按 stars 排序，查看高质量项目
gh search repos "关键词" --language=python --stars=">1000" --limit 10

# 示例：搜索 AI agent 框架
gh search repos "AI agent framework" --language=python --limit 5
```

**优势**：
- 响应快速（<2 秒）
- 结果质量高
- 可按语言、stars 过滤

#### 2. 搜索代码实现
```bash
# 查找具体实现
gh search code "函数名" --language=python --limit 5

# 示例：搜索 agent framework 实现
gh search code "agent framework" --language=python --limit 3
```

**用途**：
- 学习最佳实践
- 复用代码片段
- 了解实现细节

#### 3. 查看项目详情
```bash
# 获取项目完整信息
gh repo view owner/repo --json name,description,stargazerCount,forkCount,primaryLanguage

# 示例：查看 SuperAGI
gh repo view TransformerOptimus/SuperAGI
```

**信息包含**：
- stars/forks 数量
- 主要编程语言
- 创建和更新时间
- 项目描述

### YouTube 调研流程（谨慎使用）⚠️

#### 问题
- 访问速度慢（>30 秒）
- 可能需要代理

#### 建议
- 仅在必要时使用
- 优先使用 GitHub 文档
- 或使用其他视频平台

#### 基本用法
```bash
# 提取视频字幕
yt-dlp --write-sub --skip-download "URL"

# 获取视频信息
yt-dlp --dump-json "URL" | jq '.title, .channel, .view_count'
```

### 技术调研推荐顺序

1. **GitHub 搜索** (首选) ⭐⭐⭐
   - 快速找到相关项目
   - 查看 stars/forks 判断质量
   - 阅读 README 了解用法

2. **代码搜索** (深入) ⭐⭐
   - 找到具体实现
   - 学习最佳实践
   - 复用代码片段

3. **项目详情** (验证) ⭐⭐
   - 确认项目活跃度
   - 查看最新更新
   - 了解社区规模

4. **YouTube 教程** (补充) ⭐
   - 仅在需要视频教程时使用
   - 提前准备好等待时间

### 实战案例：React 状态管理技术选型

**调研目标**：为 React 项目选择合适的状态管理方案

**步骤 1**：搜索热门库
```bash
gh search repos "state management" --language=typescript --stars=">10000" --limit 8
```

**结果**：找到 8 个高质量项目
- Redux (61,438⭐) - 老牌方案，生态最完善
- Zustand (57,270⭐) - 新兴方案，轻量简洁
- React Query (48,719⭐) - 服务端状态管理专家
- react-hook-form (44,562⭐) - 表单状态管理
- XState (29,296⭐) - 基于 Actor 模型
- MobX (28,181⭐) - 简单可扩展
- Jotai (21,034⭐) - 原始且灵活
- boardgame.io (12,285⭐) - 游戏状态管理

**步骤 2**：深入了解 Zustand
```bash
gh repo view pmndrs/zustand
```

**发现**：
- 57,270 stars, 1,965 forks
- 最后更新：2026-03-02（5 天前）
- 活跃维护，社区活跃

**步骤 3**：搜索实际使用案例
```bash
gh search code "zustand create" --language=typescript --limit 3
```

**发现**：被 graphql/graphiql、coze-dev、jellyfin 等知名项目采用

**调研耗时**：约 5 秒完成完整调研（传统方式需 30 分钟）

**技术选型建议**：
- 小型项目：Zustand（轻量、简洁）
- 中型项目：Zustand / Jotai（灵活、性能好）
- 大型项目：Redux Toolkit（生态完善）
- 服务端状态：React Query（专业、功能全面）

---

## 📝 更新日志

| 日期 | 更新内容 | 更新者 |
|------|---------|--------|
| 2026-03-07 | 配置互联网访问工具（gh CLI + yt-dlp） | Claude |
| 2026-03-06 | 初始化长期记忆系统 | Claude |

---

> **记忆管理原则**：
> 1. 文件就是记忆 - 不要指望"心智笔记"，文件是唯一的真相
> 2. 分层管理 - MEMORY.md（长期）+ memory/日志（短期）+ AGENTS.md（规则）
> 3. 定期回顾 - 通过 heartbeat 或手动，从 daily log 提炼到 MEMORY.md
> 4. 隐私第一 - 敏感数据分离，MEMORY.md 只在主会话加载
