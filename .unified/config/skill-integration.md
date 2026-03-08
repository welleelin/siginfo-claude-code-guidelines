# 技能库整合方案

> **版本**：1.0.0
> **创建日期**：2026-03-08
> **用途**：定义技能库的整合策略和索引机制

---

## 📋 概述

本文档定义如何整合 everything-claude-code 的 50+ 技能库，建立统一的技能索引和搜索机制。

---

## 🎯 技能来源

### everything-claude-code 技能库（50+ 个）

#### 编程语言技能（10+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| golang | Go 语言开发规范 | skills/golang/ |
| cpp | C++ 开发规范 | skills/cpp/ |
| python | Python 开发规范 | skills/python/ |
| django | Django 框架 | skills/django/ |
| springboot | Spring Boot 框架 | skills/springboot/ |
| swift | Swift 开发规范 | skills/swift/ |
| rust | Rust 开发规范 | skills/rust/ |
| java | Java 开发规范 | skills/java/ |
| typescript | TypeScript 规范 | skills/typescript/ |
| javascript | JavaScript 规范 | skills/javascript/ |

#### 前后端技能（5+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| frontend-patterns | 前端开发模式 | skills/frontend-patterns/ |
| backend-patterns | 后端开发模式 | skills/backend-patterns/ |
| api-design | API 设计规范 | skills/api-design/ |
| react | React 开发规范 | skills/react/ |
| vue | Vue 开发规范 | skills/vue/ |

#### 测试技能（5+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| tdd-workflow | TDD 工作流 | skills/tdd-workflow/ |
| e2e-testing | E2E 测试 | skills/e2e-testing/ |
| eval-harness | 评估框架 | skills/eval-harness/ |
| unit-testing | 单元测试 | skills/unit-testing/ |
| integration-testing | 集成测试 | skills/integration-testing/ |

#### DevOps 技能（5+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| deployment-patterns | 部署模式 | skills/deployment-patterns/ |
| docker-patterns | Docker 模式 | skills/docker-patterns/ |
| database-migrations | 数据库迁移 | skills/database-migrations/ |
| ci-cd | CI/CD 流程 | skills/ci-cd/ |
| monitoring | 监控告警 | skills/monitoring/ |

#### AI 内容技能（5+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| continuous-learning-v2 | 持续学习系统 | skills/continuous-learning-v2/ |
| article-writing | 文章写作 | skills/article-writing/ |
| market-research | 市场调研 | skills/market-research/ |
| claude-api | Claude API 使用 | skills/claude-api/ |
| prompt-engineering | 提示词工程 | skills/prompt-engineering/ |

#### 其他技能（20+ 个）

| 技能 | 用途 | 文件 |
|------|------|------|
| security-review | 安全审查 | skills/security-review/ |
| security-scan | 安全扫描 | skills/security-scan/ |
| verification-loop | 验证循环 | skills/verification-loop/ |
| iterative-retrieval | 迭代检索 | skills/iterative-retrieval/ |
| cost-aware-llm-pipeline | 成本优化 | skills/cost-aware-llm-pipeline/ |
| postgres-patterns | PostgreSQL 模式 | skills/postgres-patterns/ |
| coding-standards | 编码标准 | skills/coding-standards/ |
| ... | ... | ... |

---

## 🔗 技能库引入方式

### 方式 1: Git Submodule（推荐）

```bash
# 在项目根目录执行
git submodule add https://github.com/your-org/everything-claude-code.git .everything-cc

# 创建符号链接到技能库
ln -s .everything-cc/skills ~/.claude/skills/everything-cc

# 更新 submodule
git submodule update --remote
```

**优点**：
- 保持与上游同步
- 版本可控
- 易于更新

**缺点**：
- 需要 Git 仓库
- 增加仓库大小

### 方式 2: 直接复制

```bash
# 克隆 everything-claude-code
git clone https://github.com/your-org/everything-claude-code.git /tmp/everything-cc

# 复制技能库
cp -r /tmp/everything-cc/skills ~/.claude/skills/everything-cc

# 清理临时文件
rm -rf /tmp/everything-cc
```

**优点**：
- 简单直接
- 不依赖 Git

**缺点**：
- 难以更新
- 无版本控制

### 方式 3: 符号链接

```bash
# 克隆到固定位置
git clone https://github.com/your-org/everything-claude-code.git ~/repos/everything-cc

# 创建符号链接
ln -s ~/repos/everything-cc/skills ~/.claude/skills/everything-cc

# 更新
cd ~/repos/everything-cc && git pull
```

**优点**：
- 易于更新
- 节省空间

**缺点**：
- 依赖外部目录
- 移动目录会失效

---

## 📊 技能索引机制

### 创建技能索引

创建 `.unified/config/skill-index.json`：

```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-03-08T00:00:00Z",
  "skills": [
    {
      "id": "golang",
      "name": "Go 语言开发规范",
      "category": "编程语言",
      "source": "everything-cc",
      "path": "~/.claude/skills/everything-cc/golang/",
      "tags": ["golang", "backend", "programming"],
      "description": "Go 语言开发规范和最佳实践",
      "triggers": ["golang", "go", "backend"],
      "priority": "P2"
    },
    {
      "id": "tdd-workflow",
      "name": "TDD 工作流",
      "category": "测试",
      "source": "everything-cc",
      "path": "~/.claude/skills/everything-cc/tdd-workflow/",
      "tags": ["tdd", "testing", "workflow"],
      "description": "测试驱动开发工作流程",
      "triggers": ["tdd", "test-driven", "testing"],
      "priority": "P2"
    },
    {
      "id": "bmad-method",
      "name": "BMAD Method 工作流",
      "category": "规划",
      "source": "BMAD Method",
      "path": "_bmad/_config/",
      "tags": ["bmad", "planning", "architecture"],
      "description": "BMAD Method 需求分析和架构设计",
      "triggers": ["bmad", "planning", "architecture"],
      "priority": "P1"
    }
  ],
  "categories": [
    "编程语言",
    "前后端",
    "测试",
    "DevOps",
    "AI 内容",
    "规划",
    "安全",
    "其他"
  ]
}
```

### 技能搜索机制

创建 `scripts/skill-search.sh`：

```bash
#!/bin/bash

# skill-search.sh - 技能搜索脚本
# 用途：搜索可用技能

SKILL_INDEX=".unified/config/skill-index.json"

search_skills() {
    local query="$1"

    # 使用 jq 搜索技能
    jq -r ".skills[] | select(
        .name | contains(\"$query\") or
        .description | contains(\"$query\") or
        .tags[] | contains(\"$query\")
    ) | \"[\(.id)] \(.name) - \(.description)\"" "$SKILL_INDEX"
}

list_categories() {
    jq -r '.categories[]' "$SKILL_INDEX"
}

list_by_category() {
    local category="$1"

    jq -r ".skills[] | select(.category == \"$category\") |
        \"[\(.id)] \(.name)\"" "$SKILL_INDEX"
}

# 主函数
main() {
    case "$1" in
        search)
            search_skills "$2"
            ;;
        categories)
            list_categories
            ;;
        category)
            list_by_category "$2"
            ;;
        *)
            echo "用法："
            echo "  $0 search <关键词>     - 搜索技能"
            echo "  $0 categories          - 列出分类"
            echo "  $0 category <分类>     - 按分类列出技能"
            ;;
    esac
}

main "$@"
```

---

## 🔍 技能组合系统

### oh-my-cc 技能组合

oh-my-cc 提供技能组合功能，可以将多个技能组合使用：

```yaml
# .unified/config/skill-combinations.yaml
combinations:
  - name: "full-stack-dev"
    description: "全栈开发技能组合"
    skills:
      - frontend-patterns
      - backend-patterns
      - api-design
      - database-migrations
      - tdd-workflow

  - name: "bmad-enterprise"
    description: "BMAD Method 企业级开发"
    skills:
      - bmad-method
      - architecture-patterns
      - security-review
      - deployment-patterns

  - name: "quick-dev"
    description: "快速开发技能组合"
    skills:
      - coding-standards
      - tdd-workflow
      - build-fix
      - refactor-clean
```

### 技能自动触发

根据文件类型或任务类型自动触发相关技能：

```json
{
  "autoTriggers": {
    "fileTypes": {
      ".go": ["golang", "backend-patterns"],
      ".py": ["python", "backend-patterns"],
      ".ts": ["typescript", "frontend-patterns"],
      ".tsx": ["typescript", "react", "frontend-patterns"]
    },
    "taskTypes": {
      "planning": ["bmad-method", "architecture-patterns"],
      "development": ["tdd-workflow", "coding-standards"],
      "testing": ["e2e-testing", "verification-loop"],
      "deployment": ["deployment-patterns", "ci-cd"]
    }
  }
}
```

---

## 📝 技能使用指南

### 查看可用技能

```bash
# 列出所有技能
/skill-list

# 搜索技能
/skill-search "golang"

# 按分类查看
./scripts/skill-search.sh category "编程语言"
```

### 使用技能

```bash
# 方式 1: 通过 Skill 工具
/skill golang

# 方式 2: 在代码中触发
# 编辑 .go 文件时自动触发 golang 技能

# 方式 3: 使用技能组合
/skill-combination full-stack-dev
```

### 创建自定义技能

```bash
# 使用 skill-create 命令
/skill-create

# 或手动创建
mkdir -p ~/.claude/skills/custom/my-skill
cat > ~/.claude/skills/custom/my-skill/SKILL.md << 'EOF'
# My Custom Skill

## Description
自定义技能描述

## Usage
使用方法

## Examples
示例代码
EOF
```

---

## 🔧 技能库维护

### 更新技能库

```bash
# 如果使用 Git Submodule
git submodule update --remote .everything-cc

# 如果使用符号链接
cd ~/repos/everything-cc && git pull

# 如果使用直接复制
# 需要重新复制
```

### 验证技能库

```bash
# 检查技能库完整性
./scripts/verify-skills.sh

# 检查技能索引
jq '.skills | length' .unified/config/skill-index.json
```

### 清理过时技能

```bash
# 列出未使用的技能
./scripts/skill-usage-report.sh

# 删除过时技能
rm -rf ~/.claude/skills/deprecated/
```

---

## 📊 技能使用统计

创建 `.unified/state/skill-usage.json`：

```json
{
  "lastUpdated": "2026-03-08T00:00:00Z",
  "usage": [
    {
      "skillId": "golang",
      "usageCount": 42,
      "lastUsed": "2026-03-08T10:00:00Z",
      "avgDuration": 120
    },
    {
      "skillId": "tdd-workflow",
      "usageCount": 38,
      "lastUsed": "2026-03-08T09:30:00Z",
      "avgDuration": 180
    }
  ],
  "topSkills": [
    "golang",
    "tdd-workflow",
    "frontend-patterns",
    "api-design",
    "security-review"
  ]
}
```

---

## 🔗 相关文档

- [命令系统合并方案](./command-merge-plan.md) - 命令系统
- [Hook 系统扩展方案](./hook-extension.md) - Hook 系统
- [集成规则](./integration-rules.md) - 规则优先级

---

*版本：1.0.0 | 创建日期：2026-03-08*
