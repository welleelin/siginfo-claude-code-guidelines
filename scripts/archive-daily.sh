#!/bin/bash

# archive-daily.sh - Daily 层归档脚本
# 每日 23:00 执行，归档当日日志并更新 MEMORY.md

set -e

# 配置
MEMORY_DIR="${MEMORY_DIR:-memory}"
MEMORY_FILE="${MEMORY_FILE:-MEMORY.md}"
STATUS_FILE="${STATUS_FILE:-.heartbeat-status.json}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[DAILY]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取今日日志文件
get_daily_file() {
    echo "${MEMORY_DIR}/$(date +%Y-%m-%d).md"
}

# 获取昨日日志文件
get_yesterday_file() {
    echo "${MEMORY_DIR}/$(date -d yesterday +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || echo "yesterday")"
}

# 从今日日志提取完成任务
extract_completed_tasks() {
    local daily_file="$1"
    if [ -f "$daily_file" ]; then
        grep -A 10 "## ✅ 今日完成" "$daily_file" 2>/dev/null | grep "\[x\]" | sed 's/^- \[x\] /  - /' || echo "  - 无"
    else
        echo "  - 无"
    fi
}

# 从今日日志提取待办事项
extract_todos() {
    local daily_file="$1"
    if [ -f "$daily_file" ]; then
        grep -A 10 "## 🔄 待办事项" "$daily_file" 2>/dev/null | grep "\[ \]" | sed 's/^- \[ \] /  - /' || echo "  - 无"
    else
        echo "  - 无"
    fi
}

# 提取技术决策
extract_decisions() {
    local daily_file="$1"
    if [ -f "$daily_file" ]; then
        grep -A 20 "## 💡 技术决策" "$daily_file" 2>/dev/null | grep -E "^- |^### " | head -10 || echo "  - 无"
    else
        echo "  - 无"
    fi
}

# 提取问题解决
extract_problems() {
    local daily_file="$1"
    if [ -f "$daily_file" ]; then
        grep -A 20 "## 🐛 问题解决" "$daily_file" 2>/dev/null | grep -E "^- |^### " | head -10 || echo "  - 无"
    else
        echo "  - 无"
    fi
}

# 生成日报摘要
generate_daily_summary() {
    local daily_file=$(get_daily_file)
    local date_str=$(date +%Y-%m-%d)
    local summary_file="${MEMORY_DIR}/summary-${date_str}.md"

    info "生成日报摘要：$summary_file"

    local completed=$(extract_completed_tasks "$daily_file")
    local todos=$(extract_todos "$daily_file")
    local decisions=$(extract_decisions "$daily_file")
    local problems=$(extract_problems "$daily_file")

    cat > "$summary_file" << EOF
# 日报摘要 - ${date_str}

> 生成时间：$(date -Iseconds)

---

## ✅ 今日完成

${completed}

## 🔄 待办事项（结转明日）

${todos}

## 💡 技术决策

${decisions}

## 🐛 问题解决

${problems}

---

## 📊 统计

- 完成任务数：$(echo "$completed" | grep -c "  - " 2>/dev/null || echo "0")
- 待办事项数：$(echo "$todos" | grep -c "  - " 2>/dev/null || echo "0")
- 技术决策数：$(echo "$decisions" | grep -c "  - " 2>/dev/null || echo "0")

---
EOF

    success "已生成日报摘要"
    echo "  文件：$summary_file"
}

# 更新 MEMORY.md
update_memory() {
    local daily_file=$(get_daily_file)

    if [ ! -f "$MEMORY_FILE" ]; then
        warning "MEMORY.md 不存在，跳过更新"
        return 0
    fi

    info "更新 MEMORY.md..."

    # 提取关键决策和教训
    local decisions=$(extract_decisions "$daily_file")
    local problems=$(extract_problems "$daily_file")

    # 如果有新的决策或教训，追加到 MEMORY.md
    if [ "$decisions" != "  - 无" ] || [ "$problems" != "  - 无" ]; then
        # 检查是否已有今日更新
        local today_marker="### $(date +%Y-%m-%d)"
        if ! grep -q "$today_marker" "$MEMORY_FILE" 2>/dev/null; then
            cat >> "$MEMORY_FILE" << EOF

---

## 📝 每日归档 - $(date +%Y-%m-%d)

### 技术决策
${decisions}

### 问题解决
${problems}

EOF
            success "已更新 MEMORY.md"
        else
            info "MEMORY.md 今日已更新，跳过"
        fi
    else
        info "无新决策或教训，跳过 MEMORY.md 更新"
    fi
}

# 准备明日待办
prepare_tomorrow_todos() {
    local tomorrow=$(date -d tomorrow +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d 2>/dev/null)
    local tomorrow_file="${MEMORY_DIR}/${tomorrow}.md"
    local today_file=$(get_daily_file)

    info "准备明日待办：$tomorrow_file"

    # 从今日日志中提取未完成的待办
    local pending_todos=""
    if [ -f "$today_file" ]; then
        pending_todos=$(grep -A 100 "## 🔄 待办事项" "$today_file" 2>/dev/null | grep "\[ \]" | head -10 || echo "")
    fi

    if [ -n "$pending_todos" ]; then
        # 创建明日日志文件（如果不存在）
        if [ ! -f "$tomorrow_file" ]; then
            cat > "$tomorrow_file" << EOF
# 记忆日志 - ${tomorrow}

> 创建时间：$(date -Iseconds)
> 状态：pending

---

## 📋 预加载待办事项

从 $(date +%Y-%m-%d) 结转：

${pending_todos}

---

## 📝 待更新

请在会话开始后更新以下内容：
- 今日任务
- Hourly 层记录
- 会话摘要

---
EOF
            success "已创建明日日志（含结转待办）"
        fi
    else
        info "无待结转事项"
    fi
}

# 更新心跳状态
update_heartbeat_status() {
    local timestamp=$(date -Iseconds)

    local hourly_status=$(jq -r '.hourly.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")
    local daily_status="ok"
    local weekly_status=$(jq -r '.weekly.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")

    cat > "$STATUS_FILE" << EOF
{
  "hourly": {
    "lastCheck": "$(jq -r '.hourly.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$hourly_status"
  },
  "daily": {
    "lastCheck": "$timestamp",
    "status": "$daily_status"
  },
  "weekly": {
    "lastCheck": "$(jq -r '.weekly.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$weekly_status"
  }
}
EOF
}

# 生成归档报告
generate_archive_report() {
    local daily_file=$(get_daily_file)

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "                    日终归档报告                           "
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "日期：$(date +%Y-%m-%d)"
    echo "时间：$(date +%H:%M)"
    echo ""

    if [ -f "$daily_file" ]; then
        echo "📋 今日日志：$daily_file"
        echo ""

        # 统计
        local hour_sections=$(grep -c "### [0-9][0-9]:00" "$daily_file" 2>/dev/null || echo "0")
        local completed=$(grep -c "\[x\]" "$daily_file" 2>/dev/null || echo "0")
        local pending=$(grep -c "\[ \]" "$daily_file" 2>/dev/null || echo "0")

        echo "统计:"
        echo "  - Hourly 同步次数：$hour_sections"
        echo "  - 完成任务数：$completed"
        echo "  - 待办事项数：$pending"
    else
        echo "⚠️ 今日日志不存在"
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

# 主函数
main() {
    case "${1:-archive}" in
        archive)
            generate_daily_summary
            update_memory
            prepare_tomorrow_todos
            update_heartbeat_status
            generate_archive_report
            ;;
        summary)
            generate_daily_summary
            ;;
        report)
            generate_archive_report
            ;;
        -h|--help)
            cat << EOF
用法：$0 [命令]

命令:
  archive   执行完整归档流程（默认）
  summary   仅生成日报摘要
  report    仅生成归档报告
  help      显示帮助

说明:
  归档流程包括:
  1. 生成日报摘要
  2. 更新 MEMORY.md
  3. 准备明日待办
  4. 更新心跳状态

建议:
  每日 23:00 执行，可配置 cron 定时任务

EOF
            ;;
        *)
            archive
            ;;
    esac
}

main "$@"
