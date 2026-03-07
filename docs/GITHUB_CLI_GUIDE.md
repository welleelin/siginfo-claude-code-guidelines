# GitHub CLI 使用手册

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

GitHub CLI (gh) 是 GitHub 官方命令行工具，提供快速、高效的 GitHub 访问能力。

### 核心优势

| 特性 | 说明 |
|------|------|
| ⚡ 速度快 | 所有查询 <2 秒响应 |
| 📊 信息全 | stars、forks、更新时间一目了然 |
| 🤖 可编程 | JSON 输出便于自动化 |
| 🔒 安全 | 使用 GitHub Token 认证 |

---

## 🚀 快速开始

### 安装

```bash
# macOS
brew install gh

# 验证安装
gh --version
```

### 认证

```bash
# 登录 GitHub
gh auth login

# 查看认证状态
gh auth status
```

---

## 📚 基本用法

### 1. 仓库搜索

#### 基本搜索
```bash
# 搜索仓库
gh search repos "关键词"

# 限制结果数量
gh search repos "关键词" --limit 10
```

#### 高级搜索
```bash
# 按语言过滤
gh search repos "AI agent" --language=python

# 按 stars 过滤
gh search repos "state management" --stars=">10000"

# 组合条件
gh search repos "react" --language=typescript --stars=">5000" --limit 10
```

#### JSON 输出
```bash
# 输出 JSON 格式
gh search repos "zustand" --json name,description,stargazersCount,url

# 使用 jq 格式化
gh search repos "zustand" --json name,stargazersCount | jq
```

### 2. 代码搜索

#### 基本搜索
```bash
# 搜索代码
gh search code "函数名"

# 按语言过滤
gh search code "useState" --language=typescript
```

#### 高级搜索
```bash
# 搜索特定文件
gh search code "zustand create" --filename="store.ts"

# 搜索特定路径
gh search code "config" --path="src/config"

# 组合条件
gh search code "agent framework" --language=python --limit 5
```

### 3. 仓库详情

#### 查看仓库
```bash
# 基本信息
gh repo view owner/repo

# JSON 输出
gh repo view owner/repo --json name,description,stargazerCount,forkCount
```

#### 可用字段
```bash
# 查看所有可用字段
gh repo view owner/repo --json help

# 常用字段
--json name,description,stargazerCount,forkCount,primaryLanguage,createdAt,pushedAt,url
```

---

## 🎯 实战案例

### 案例 1: React 状态管理技术选型

**目标**：为 React 项目选择合适的状态管理方案

#### 步骤 1: 搜索热门库
```bash
gh search repos "state management" \
  --language=typescript \
  --stars=">10000" \
  --limit 8 \
  --json name,description,stargazersCount,url
```

**结果**：
- Redux (61,438⭐)
- Zustand (57,270⭐)
- React Query (48,719⭐)
- react-hook-form (44,562⭐)
- XState (29,296⭐)
- MobX (28,181⭐)
- Jotai (21,034⭐)
- boardgame.io (12,285⭐)

#### 步骤 2: 深入了解 Zustand
```bash
gh repo view pmndrs/zustand \
  --json name,description,stargazerCount,forkCount,pushedAt,homepageUrl
```

**发现**：
- 57,270 stars, 1,965 forks
- 最后更新：2026-03-02（活跃维护）
- 官网：https://zustand-demo.pmnd.rs/

#### 步骤 3: 搜索实际使用案例
```bash
gh search code "zustand create" \
  --language=typescript \
  --limit 3 \
  --json repository,path,url
```

**发现**：被 graphql/graphiql、coze-dev、jellyfin 等知名项目采用

#### 结论
- 总耗时：约 5 秒
- 找到 8 个高质量项目
- 深入分析 1 个候选方案
- 搜索到 3 个真实案例

### 案例 2: 寻找 AI Agent 框架

```bash
# 搜索 Python AI agent 框架
gh search repos "AI agent framework" \
  --language=python \
  --stars=">1000" \
  --limit 10 \
  --json name,description,stargazersCount,url \
  | jq -r '.[] | "\(.name) (\(.stargazersCount)⭐) - \(.description)"'
```

### 案例 3: 学习最佳实践

```bash
# 搜索 React Hooks 最佳实践
gh search code "custom hooks best practices" \
  --language=typescript \
  --limit 5 \
  --json repository,path,url
```

---

## 🔧 高级技巧

### 1. 组合多个条件

```bash
# 搜索活跃维护的项目
gh search repos "react" \
  --language=typescript \
  --stars=">5000" \
  --pushed=">2026-01-01" \
  --limit 10
```

### 2. 使用 jq 处理 JSON

```bash
# 提取特定字段
gh search repos "zustand" --json name,stargazersCount \
  | jq -r '.[] | "\(.name): \(.stargazersCount) stars"'

# 排序
gh search repos "state management" --json name,stargazersCount \
  | jq 'sort_by(.stargazersCount) | reverse'

# 过滤
gh search repos "react" --json name,stargazersCount \
  | jq '.[] | select(.stargazersCount > 10000)'
```

### 3. 自动化脚本

```bash
#!/bin/bash
# tech-research.sh - 技术调研自动化脚本

KEYWORD="$1"
LANGUAGE="${2:-typescript}"
MIN_STARS="${3:-5000}"

echo "=== 搜索 $KEYWORD ==="
gh search repos "$KEYWORD" \
  --language="$LANGUAGE" \
  --stars=">$MIN_STARS" \
  --limit 10 \
  --json name,description,stargazersCount,url \
  | jq -r '.[] | "[\(.name)](\(.url)) - \(.stargazersCount)⭐\n  \(.description)\n"'
```

使用：
```bash
./tech-research.sh "state management" typescript 10000
```

---

## 📊 常用搜索模式

### 按项目规模

```bash
# 大型项目 (>10K stars)
gh search repos "关键词" --stars=">10000"

# 中型项目 (1K-10K stars)
gh search repos "关键词" --stars="1000..10000"

# 新兴项目 (<1K stars, 最近更新)
gh search repos "关键词" --stars="<1000" --pushed=">2026-01-01"
```

### 按活跃度

```bash
# 最近更新
gh search repos "关键词" --pushed=">2026-01-01"

# 最近创建
gh search repos "关键词" --created=">2026-01-01"

# 活跃维护（最近 30 天有更新）
gh search repos "关键词" --pushed=">2026-02-01"
```

### 按语言

```bash
# TypeScript
gh search repos "关键词" --language=typescript

# Python
gh search repos "关键词" --language=python

# Go
gh search repos "关键词" --language=go
```

---

## ❓ 常见问题

### Q1: 如何提高搜索准确性？

**A**: 使用多个条件组合

```bash
# 不够精确
gh search repos "react"

# 更精确
gh search repos "react state management" \
  --language=typescript \
  --stars=">5000"
```

### Q2: 如何避免 API 限流？

**A**: 使用认证 Token

```bash
# 登录后自动使用 Token
gh auth login

# 查看限流状态
gh api rate_limit
```

### Q3: 如何搜索特定组织的仓库？

**A**: 使用 org: 限定符

```bash
gh search repos "org:facebook react"
```

### Q4: 如何搜索 README 内容？

**A**: 使用 in:readme 限定符

```bash
gh search code "installation guide" --match=file --filename=README.md
```

### Q5: 字段名不确定怎么办？

**A**: 使用 help 查看可用字段

```bash
# 查看 search repos 可用字段
gh search repos "test" --json help

# 查看 repo view 可用字段
gh repo view owner/repo --json help
```

---

## 🎓 最佳实践

### 1. 技术调研流程

```
1. 搜索相关项目 (gh search repos)
   ↓
2. 查看项目详情 (gh repo view)
   ↓
3. 搜索代码示例 (gh search code)
   ↓
4. 记录到 MEMORY.md
```

### 2. 结果记录

```bash
# 将结果保存到文件
gh search repos "zustand" --json name,stargazersCount > results.json

# 追加到日志
gh search repos "zustand" --json name,stargazersCount >> memory/$(date +%Y-%m-%d).md
```

### 3. 定期更新

```bash
# 检查项目更新
gh repo view owner/repo --json pushedAt

# 查看最新 Release
gh release list --repo owner/repo --limit 5
```

---

## 🔗 相关资源

- [GitHub CLI 官方文档](https://cli.github.com/manual/)
- [GitHub Search 语法](https://docs.github.com/en/search-github/searching-on-github)
- [jq 手册](https://stedolan.github.io/jq/manual/)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|---------|
| 2026-03-07 | 1.0.0 | 初始版本，包含基本用法和实战案例 |

---

> **提示**：将常用命令保存到 MEMORY.md，方便随时查阅和复用。
