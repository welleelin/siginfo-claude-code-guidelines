# 自动化脚本示例

> 版本：1.0.0
> 最后更新：2026-03-07

---

## 📋 概述

本文档提供常用自动化脚本的实战示例，帮助快速实现项目自动化。

---

## 🔧 记忆系统自动化

### 示例 1: 自动小时同步

**场景**：每小时自动同步当前会话状态到记忆系统

**脚本**: `scripts/sync-hourly.sh`

```bash
#!/bin/bash
# sync-hourly.sh - 每小时同步记忆

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/memory"
TODAY=$(date +%Y-%m-%d)
MEMORY_FILE="$MEMORY_DIR/$TODAY.md"

echo "=== 小时同步开始 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. 确保今日记忆文件存在
if [ ! -f "$MEMORY_FILE" ]; then
    echo "创建今日记忆文件: $MEMORY_FILE"
    cat > "$MEMORY_FILE" <<EOF
# $TODAY 工作日志

> 创建时间：$(date '+%Y-%m-%dT%H:%M:%S%z')

---

## 📋 今日任务

### 任务列表
- [ ] 任务 1
- [ ] 任务 2

---

## 💡 技术决策

### 决策记录
- 暂无

---

## 🔗 相关链接
- 暂无

---

## 📝 待办事项
- [ ] 待办 1
- [ ] 待办 2

EOF
fi

# 2. 记录心跳时间
HEARTBEAT_FILE="$PROJECT_ROOT/.heartbeat-status.json"
cat > "$HEARTBEAT_FILE" <<EOF
{
  "hourly": {
    "lastCheck": "$(date -u +%Y-%m-%dT%H:%M:%S%z)",
    "status": "ok"
  }
}
EOF

echo "✅ 小时同步完成"
```

**使用方法**:
```bash
# 手动执行
./scripts/sync-hourly.sh

# 配置 cron 每小时执行
0 * * * * cd /path/to/project && ./scripts/sync-hourly.sh
```

---

### 示例 2: 自动日终归档

**场景**：每日 23:00 自动归档当日记忆

**脚本**: `scripts/archive-daily.sh`

```bash
#!/bin/bash
# archive-daily.sh - 每日归档记忆

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/memory"
MEMORY_FILE="$PROJECT_ROOT/MEMORY.md"
TODAY=$(date +%Y-%m-%d)
TODAY_LOG="$MEMORY_DIR/$TODAY.md"

echo "=== 日终归档开始 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. 检查今日日志是否存在
if [ ! -f "$TODAY_LOG" ]; then
    echo "⚠️  今日日志不存在: $TODAY_LOG"
    exit 0
fi

# 2. 提取今日关键决策
echo "提取今日关键决策..."
DECISIONS=$(grep -A 5 "## 💡 技术决策" "$TODAY_LOG" | tail -n +2 || echo "无")

# 3. 提取今日待办
echo "提取今日待办..."
TODOS=$(grep "^- \[ \]" "$TODAY_LOG" || echo "无")

# 4. 生成日报
DAILY_REPORT="$MEMORY_DIR/daily-report-$TODAY.md"
cat > "$DAILY_REPORT" <<EOF
# $TODAY 日报

## 完成任务
$(grep "^- \[x\]" "$TODAY_LOG" || echo "- 无")

## 技术决策
$DECISIONS

## 明日待办
$TODOS

---
生成时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

echo "✅ 日报已生成: $DAILY_REPORT"

# 5. 更新心跳状态
HEARTBEAT_FILE="$PROJECT_ROOT/.heartbeat-status.json"
cat > "$HEARTBEAT_FILE" <<EOF
{
  "daily": {
    "lastCheck": "$(date -u +%Y-%m-%dT%H:%M:%S%z)",
    "status": "ok"
  }
}
EOF

echo "✅ 日终归档完成"
```

**使用方法**:
```bash
# 手动执行
./scripts/archive-daily.sh

# 配置 cron 每日 23:00 执行
0 23 * * * cd /path/to/project && ./scripts/archive-daily.sh
```

---

## 🧪 测试自动化

### 示例 3: 自动运行测试并生成报告

**场景**：提交代码前自动运行测试

**脚本**: `scripts/run-tests.sh`

```bash
#!/bin/bash
# run-tests.sh - 运行测试并生成报告

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/test-reports"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "=== 测试开始 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. 创建报告目录
mkdir -p "$REPORT_DIR"

# 2. 运行单元测试
echo "运行单元测试..."
npm test -- --coverage --json --outputFile="$REPORT_DIR/unit-$TIMESTAMP.json" || true

# 3. 运行 E2E 测试
echo "运行 E2E 测试..."
npx playwright test --reporter=json --output="$REPORT_DIR/e2e-$TIMESTAMP.json" || true

# 4. 生成测试报告
REPORT_FILE="$REPORT_DIR/report-$TIMESTAMP.md"
cat > "$REPORT_FILE" <<EOF
# 测试报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 单元测试
- 报告: unit-$TIMESTAMP.json

## E2E 测试
- 报告: e2e-$TIMESTAMP.json

---
EOF

echo "✅ 测试完成，报告: $REPORT_FILE"
```

**使用方法**:
```bash
# 手动执行
./scripts/run-tests.sh

# Git pre-commit hook
# .git/hooks/pre-commit
#!/bin/bash
./scripts/run-tests.sh
```

---

## 📦 部署自动化

### 示例 4: 自动构建和部署

**场景**：推送到 main 分支后自动部署

**脚本**: `scripts/deploy.sh`

```bash
#!/bin/bash
# deploy.sh - 自动构建和部署

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/dist"
DEPLOY_LOG="$PROJECT_ROOT/deploy.log"

echo "=== 部署开始 ===" | tee -a "$DEPLOY_LOG"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$DEPLOY_LOG"

# 1. 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ 错误：只能从 main 分支部署" | tee -a "$DEPLOY_LOG"
    exit 1
fi

# 2. 拉取最新代码
echo "拉取最新代码..." | tee -a "$DEPLOY_LOG"
git pull origin main

# 3. 安装依赖
echo "安装依赖..." | tee -a "$DEPLOY_LOG"
npm ci

# 4. 运行测试
echo "运行测试..." | tee -a "$DEPLOY_LOG"
npm test

# 5. 构建项目
echo "构建项目..." | tee -a "$DEPLOY_LOG"
npm run build

# 6. 部署到服务器
echo "部署到服务器..." | tee -a "$DEPLOY_LOG"
rsync -avz --delete "$BUILD_DIR/" user@server:/var/www/html/

echo "✅ 部署完成" | tee -a "$DEPLOY_LOG"
```

**使用方法**:
```bash
# 手动部署
./scripts/deploy.sh

# GitHub Actions 自动部署
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./scripts/deploy.sh
```

---

## 🔍 代码质量自动化

### 示例 5: 自动代码检查

**场景**：提交前自动检查代码质量

**脚本**: `scripts/lint-check.sh`

```bash
#!/bin/bash
# lint-check.sh - 代码质量检查

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== 代码质量检查开始 ==="

# 1. ESLint 检查
echo "运行 ESLint..."
npm run lint

# 2. TypeScript 类型检查
echo "运行 TypeScript 类型检查..."
npm run type-check

# 3. Prettier 格式检查
echo "运行 Prettier 格式检查..."
npm run format:check

# 4. 检查未提交的文件
UNSTAGED=$(git diff --name-only)
if [ -n "$UNSTAGED" ]; then
    echo "⚠️  警告：有未暂存的文件"
    echo "$UNSTAGED"
fi

echo "✅ 代码质量检查通过"
```

**使用方法**:
```bash
# 手动执行
./scripts/lint-check.sh

# Git pre-commit hook
# .git/hooks/pre-commit
#!/bin/bash
./scripts/lint-check.sh
```

---

## 📊 监控自动化

### 示例 6: 自动健康检查

**场景**：定期检查服务健康状态

**脚本**: `scripts/health-check.sh`

```bash
#!/bin/bash
# health-check.sh - 服务健康检查

set -e

API_URL="${API_URL:-http://localhost:3000}"
HEALTH_ENDPOINT="$API_URL/health"
ALERT_EMAIL="${ALERT_EMAIL:-admin@example.com}"

echo "=== 健康检查开始 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "检查地址: $HEALTH_ENDPOINT"

# 1. 检查服务是否响应
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_ENDPOINT" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ 服务正常 (HTTP $HTTP_CODE)"
    exit 0
else
    echo "❌ 服务异常 (HTTP $HTTP_CODE)"

    # 2. 发送告警邮件
    echo "发送告警邮件到: $ALERT_EMAIL"
    echo "服务健康检查失败 (HTTP $HTTP_CODE)" | \
        mail -s "⚠️ 服务告警" "$ALERT_EMAIL"

    exit 1
fi
```

**使用方法**:
```bash
# 手动执行
./scripts/health-check.sh

# 配置 cron 每 5 分钟检查
*/5 * * * * cd /path/to/project && ./scripts/health-check.sh
```

---

## 🔄 Git 自动化

### 示例 7: 自动提交和推送

**场景**：定期自动提交和推送更改

**脚本**: `scripts/auto-commit.sh`

```bash
#!/bin/bash
# auto-commit.sh - 自动提交和推送

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 自动提交开始 ==="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 1. 检查是否有更改
if [ -z "$(git status --porcelain)" ]; then
    echo "没有更改需要提交"
    exit 0
fi

# 2. 添加所有更改
echo "添加更改..."
git add .

# 3. 生成提交信息
COMMIT_MSG="chore: 自动提交 $(date '+%Y-%m-%d %H:%M:%S')"

# 4. 提交
echo "提交更改..."
git commit -m "$COMMIT_MSG"

# 5. 推送到远程
echo "推送到远程..."
git push origin $(git branch --show-current)

echo "✅ 自动提交完成"
```

**使用方法**:
```bash
# 手动执行
./scripts/auto-commit.sh

# 配置 cron 每小时自动提交
0 * * * * cd /path/to/project && ./scripts/auto-commit.sh
```

---

## 🛠️ 开发环境自动化

### 示例 8: 自动环境配置

**场景**：新项目快速配置开发环境

**脚本**: `scripts/setup-dev.sh`

```bash
#!/bin/bash
# setup-dev.sh - 配置开发环境

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== 开发环境配置开始 ==="

# 1. 检查 Node.js 版本
echo "检查 Node.js 版本..."
NODE_VERSION=$(node -v)
echo "当前 Node.js 版本: $NODE_VERSION"

# 2. 安装依赖
echo "安装依赖..."
npm install

# 3. 复制环境变量文件
if [ ! -f ".env" ]; then
    echo "创建 .env 文件..."
    cp .env.example .env
    echo "⚠️  请编辑 .env 文件配置环境变量"
fi

# 4. 初始化数据库
if [ -f "scripts/init-db.sh" ]; then
    echo "初始化数据库..."
    ./scripts/init-db.sh
fi

# 5. 运行初始构建
echo "运行初始构建..."
npm run build

# 6. 配置 Git hooks
echo "配置 Git hooks..."
npx husky install

echo "✅ 开发环境配置完成"
echo ""
echo "下一步:"
echo "  1. 编辑 .env 文件"
echo "  2. 运行 npm run dev 启动开发服务器"
```

**使用方法**:
```bash
# 新项目初始化
./scripts/setup-dev.sh
```

---

## 📝 文档自动化

### 示例 9: 自动生成 API 文档

**场景**：从代码注释自动生成 API 文档

**脚本**: `scripts/generate-docs.sh`

```bash
#!/bin/bash
# generate-docs.sh - 生成 API 文档

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs/api"

echo "=== API 文档生成开始 ==="

# 1. 创建文档目录
mkdir -p "$DOCS_DIR"

# 2. 使用 TypeDoc 生成文档
echo "生成 TypeScript API 文档..."
npx typedoc --out "$DOCS_DIR" src/

# 3. 生成 README
cat > "$DOCS_DIR/README.md" <<EOF
# API 文档

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 目录

- [Classes](classes.html)
- [Interfaces](interfaces.html)
- [Functions](functions.html)

---

自动生成，请勿手动编辑
EOF

echo "✅ API 文档生成完成: $DOCS_DIR"
```

**使用方法**:
```bash
# 手动生成
./scripts/generate-docs.sh

# Git pre-commit hook 自动生成
# .git/hooks/pre-commit
#!/bin/bash
./scripts/generate-docs.sh
git add docs/api/
```

---

## 🔗 相关文档

- [脚本使用说明](README.md)
- [长期记忆管理规范](../guidelines/11-LONG_TERM_MEMORY.md)
- [GitHub CLI 使用手册](GITHUB_CLI_GUIDE.md)

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 | 更新人 |
|------|------|---------|--------|
| 2026-03-07 | 1.0.0 | 初始版本，包含 9 个实战示例 | - |

---

> **使用提示**：
> 1. 根据项目需求选择合适的脚本
> 2. 修改脚本中的配置参数
> 3. 添加执行权限：`chmod +x scripts/*.sh`
> 4. 配置 cron 实现定时执行
> 5. 使用 Git hooks 实现自动触发
