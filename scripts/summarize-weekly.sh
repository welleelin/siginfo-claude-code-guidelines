#!/bin/bash

# summarize-weekly.sh - Weekly 层总结脚本
# 每周日 22:00 执行，总结本周并更新 MEMORY.md

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
    echo -e "${BLUE}[WEEKLY]${NC} $1"
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

# 获取本周日期范围
get_week_range() {
    local today=$(date +%Y-%m-%d)
    local monday=$(date -d "last monday" +%Y-%m-%d 2>/dev/null || date -v-mon +%Y-%m-%d 2>/dev/null || echo "$today")
    local sunday=$(date -d "next sunday" +%Y-%m-%d 2>/dev/null || date -v-sun +%Y-%m-%d 2>/dev/null || echo "$today")
    echo "$monday $sunday"
}

# 获取本周日志文件列表
get_week_files() {
    local start_date="$1"
    local end_date="$1"
    local files=()

    # 简单实现：获取最近 7 天的文件
    for i in {0..6}; do
        local date=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null || date -v-${i}d +%Y-%m-%d 2>/dev/null)
        local file="${MEMORY_DIR}/${date}.md"
        if [ -f "$file" ]; then
            files+=("$file")
        fi
    done

    echo "${files[@]}"
}

# 提取本周完成任务
extract_weekly_completed() {
    local files="$1"
    local completed=""

    for file in $files; do
        if [ -f "$file" ]; then
            local section=$(grep -A 20 "## ✅ 今日完成" "$file" 2>/dev/null | grep "\[x\]" | sed 's/^- \[x\] /  - /')
            if [ -n "$section" ]; then
                completed="${completed}\n$(basename $file .md):\n${section}"
            fi
        fi
    done

    echo -e "$completed" | grep -v "^$" || echo "  - 无"
}

# 提取本周技术决策
extract_weekly_decisions() {
    local files="$1"
    local decisions=""

    for file in $files; do
        if [ -f "$file" ]; then
            local section=$(grep -A 20 "## 💡 技术决策" "$file" 2>/dev/null | grep -E "^- |^### " | head -5)
            if [ -n "$section" ]; then
                decisions="${decisions}\n$(basename $file .md):\n${section}"
            fi
        fi
    done

    echo -e "$decisions" | grep -v "^$" || echo "  - 无"
}

# 提取本周问题解决
extract_weekly_problems() {
    local files="$1"
    local problems=""

    for file in $files; do
        if [ -f "$file" ]; then
            local section=$(grep -A 20 "## 🐛 问题解决" "$file" 2>/dev/null | grep -E "^- |^### " | head -5)
            if [ -n "$section" ]; then
                problems="${problems}\n$(basename $file .md):\n${section}"
            fi
        fi
    done

    echo -e "$problems" | grep -v "^$" || echo "  - 无"
}

# 生成周报
generate_weekly_report() {
    local week_start=$(date -d "last monday" +%Y-%m-%d 2>/dev/null || echo "unknown")
    local week_end=$(date -d "next sunday" +%Y-%m-%d 2>/dev/null || echo "unknown")
    local week_number=$(date +%Y-W%W)
    local report_file="${MEMORY_DIR}/weekly-report-${week_number}.md"

    info "生成周报：$report_file"

    local files=$(get_week_files)
    local completed=$(extract_weekly_completed "$files")
    local decisions=$(extract_weekly_decisions "$files")
    local problems=$(extract_weekly_problems "$files")

    # 统计
    local total_files=$(echo "$files" | wc -w)
    local completed_count=$(echo -e "$completed" | grep -c "  - " 2>/dev/null || echo "0")
    local decisions_count=$(echo -e "$decisions" | grep -c "  - " 2>/dev/null || echo "0")
    local problems_count=$(echo -e "$problems" | grep -c "  - " 2>/dev/null || echo "0")

    cat > "$report_file" << EOF
# 周报 - ${week_number}

> 周期：${week_start} ~ ${week_end}
> 生成时间：$(date -Iseconds)

---

## 📊 本周概览

| 指标 | 数值 |
|------|------|
| 日志天数 | ${total_files} |
| 完成任务数 | ${completed_count} |
| 技术决策数 | ${decisions_count} |
| 问题解决数 | ${problems_count} |

---

## ✅ 本周完成

${completed}

---

## 💡 技术决策

${decisions}

---

## 🐛 问题解决

${problems}

---

## 🌟 本周亮点

> 待填写

-

---

## 📈 改进建议

> 待填写

-

---

## 📋 下周计划

> 待填写

-

---
EOF

    success "已生成周报"
    echo "  文件：$report_file"
}

# 更新 MEMORY.md（长期记忆层）
update_memory_weekly() {
    if [ ! -f "$MEMORY_FILE" ]; then
        warning "MEMORY.md 不存在，跳过更新"
        return 0
    fi

    info "更新 MEMORY.md（长期记忆层）..."

    local files=$(get_week_files)
    local decisions=$(extract_weekly_decisions "$files")
    local problems=$(extract_weekly_problems "$files")

    # 检查是否已有本周更新
    local week_number=$(date +%Y-W%W)
    local week_marker="## 📝 周报归档 - ${week_number}"

    if ! grep -q "$week_marker" "$MEMORY_FILE" 2>/dev/null; then
        # 追加到经验教训章节
        local week_start=$(date -d "last monday" +%Y-%m-%d 2>/dev/null || echo "unknown")
        local week_end=$(date -d "next sunday" +%Y-%m-%d 2>/dev/null || echo "unknown")

        cat >> "$MEMORY_FILE" << EOF

---

## 📝 周报归档 - ${week_number}

周期：${week_start} ~ ${week_end}

### 技术决策
${decisions}

### 问题解决
${problems}

EOF
        success "已更新 MEMORY.md"
    else
        info "MEMORY.md 本周已更新，跳过"
    fi
}

# 清理过时的每日日志（可选，保留最近 30 天）
cleanup_old_logs() {
    local keep_days="${1:-30}"
    info "清理 ${keep_days} 天前的日志..."

    local deleted=0
    for file in "${MEMORY_DIR}"/*.md; do
        if [ -f "$file" ]; then
            local file_date=$(basename "$file" .md)
            if [[ "$file_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                local file_ts=$(date -d "$file_date" +%s 2>/dev/null || echo "0")
                local cutoff_ts=$(date -d "${keep_days} days ago" +%s 2>/dev/null || echo "0")

                if [ "$file_ts" -lt "$cutoff_ts" ] && [[ ! "$(basename "$file")" =~ weekly ]]; then
                    # 归档而不是删除
                    local archive_dir="${MEMORY_DIR}/.archive"
                    mkdir -p "$archive_dir"
                    mv "$file" "$archive_dir/"
                    ((deleted++))
                    info "归档：$file"
                fi
            fi
        fi
    done

    success "已归档 $deleted 个旧日志文件"
}

# 更新心跳状态
update_heartbeat_status() {
    local timestamp=$(date -Iseconds)

    local hourly_status=$(jq -r '.hourly.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")
    local daily_status=$(jq -r '.daily.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")
    local weekly_status="ok"

    cat > "$STATUS_FILE" << EOF
{
  "hourly": {
    "lastCheck": "$(jq -r '.hourly.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$hourly_status"
  },
  "daily": {
    "lastCheck": "$(jq -r '.daily.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$daily_status"
  },
  "weekly": {
    "lastCheck": "$timestamp",
    "status": "$weekly_status"
  }
}
EOF
}

# 生成周报摘要
generate_weekly_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "                    周度总结报告                           "
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "周期：$(date +%Y-W%W)"
    echo "日期：$(date -d "last monday" +%Y-%m-%d 2>/dev/null || echo "unknown") ~ $(date -d "next sunday" +%Y-%m-%d 2>/dev/null || echo "unknown")"
    echo ""

    local files=$(get_week_files)
    local total_files=$(echo "$files" | wc -w)
    local completed=$(extract_weekly_completed "$files")
    local decisions=$(extract_weekly_decisions "$files")

    echo "📊 统计:"
    echo "  - 日志文件数：$total_files"
    echo "  - 完成任务数：$(echo -e "$completed" | grep -c "  - " 2>/dev/null || echo "0")"
    echo "  - 技术决策数：$(echo -e "$decisions" | grep -c "  - " 2>/dev/null || echo "0")"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

# 主函数
main() {
    case "${1:-summarize}" in
        summarize)
            generate_weekly_report
            update_memory_weekly
            update_heartbeat_status
            generate_weekly_summary
            ;;
        report)
            generate_weekly_report
            ;;
        update)
            update_memory_weekly
            ;;
        cleanup)
            cleanup_old_logs "${2:-30}"
            ;;
        summary)
            generate_weekly_summary
            ;;
        -h|--help)
            cat << EOF
用法：$0 [命令] [选项]

命令:
  summarize     执行完整周度总结（默认）
  report        仅生成周报
  update        仅更新 MEMORY.md
  cleanup       清理旧日志（默认保留 30 天）
  summary       显示周报摘要
  help          显示帮助

选项:
  --keep-days   清理时保留的天数（默认 30）

说明:
  周度总结流程包括:
  1. 生成周报（聚合本周所有日志）
  2. 更新 MEMORY.md（长期记忆层）
  3. 更新心跳状态
  4. 显示周报摘要

建议:
  每周日 22:00 执行，可配置 cron 定时任务
  0 22 * * 0 /path/to/summarize-weekly.sh

EOF
            ;;
        *)
            summarize
            ;;
    esac
}

main "$@"
