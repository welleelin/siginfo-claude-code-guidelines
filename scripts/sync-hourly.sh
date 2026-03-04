#!/bin/bash

# sync-hourly.sh - Hourly 层同步脚本
# 每小时执行一次，同步当前会话状态到 memory 文件

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
    echo -e "${BLUE}[HOURLY]${NC} $1"
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

# 确保目录存在
ensure_dirs() {
    mkdir -p "$MEMORY_DIR"
}

# 获取当前小时
get_current_hour() {
    date +%H
}

# 获取今日日志文件
get_daily_file() {
    echo "${MEMORY_DIR}/$(date +%Y-%m-%d).md"
}

# 获取任务 ID
get_task_id() {
    if [ -n "$TASK_ID" ]; then
        echo "$TASK_ID"
    elif [ -f "$MEMORY_FILE" ]; then
        grep -o '"taskId": "[^"]*"' "$MEMORY_FILE" 2>/dev/null | head -1 | cut -d'"' -f4 || echo "unknown"
    else
        echo "unknown"
    fi
}

# 获取当前阶段
get_current_phase() {
    if [ -f "$MEMORY_FILE" ]; then
        grep -o '"currentPhase": "[^"]*"' "$MEMORY_FILE" 2>/dev/null | cut -d'"' -f4 || echo "unknown"
    else
        echo "unknown"
    fi
}

# 获取 Git 状态摘要
get_git_summary() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")
    local changes=$(git diff --stat 2>/dev/null | tail -1 || echo "")
    echo "分支：$branch, $changes"
}

# 同步 Hourly 层
sync_hourly() {
    local hour=$(get_current_hour)
    local daily_file=$(get_daily_file)
    local task_id=$(get_task_id)
    local phase=$(get_current_phase)
    local git_summary=$(get_git_summary)
    local timestamp=$(date -Iseconds)

    ensure_dirs

    info "执行 Hourly 同步 - ${hour}:00"
    echo "  任务：$task_id"
    echo "  阶段：$phase"
    echo "  Git: $git_summary"
    echo ""

    # 如果今日日志不存在，创建它
    if [ ! -f "$daily_file" ]; then
        info "创建今日日志：$daily_file"
        cat > "$daily_file" << EOF
# 记忆日志 - $(date +%Y-%m-%d)

> 创建时间：$timestamp
> 状态：active

---

## 📋 今日任务

| 任务 ID | 任务标题 | 状态 | 进度 | 备注 |
|--------|---------|------|------|------|
| $task_id | - | in_progress | 0% | - |

---

## 🕐 Hourly 层 - 实时记录

### ${hour}:00 - 整点同步
- **时间**：$timestamp
- **类型**：hourly_sync
- **任务**：$task_id
- **阶段**：$phase
- **Git 状态**：$git_summary
- **内容**：
  整点自动同步，记录当前状态
- **标签**：hourly, checkpoint, state

---

## ✅ 今日完成

- [ ] 待更新

---

## 🔄 待办事项

- [ ] 待更新

---

## 📊 会话摘要

| 会话 ID | 开始时间 | 结束时间 | 主要活动 | 关键产出 |
|--------|---------|---------|---------|---------|
| auto | - | - | - | - |

---
EOF
        success "已创建今日日志"
    else
        # 检查是否已有本小时的记录
        local hour_marker="### ${hour}:00 - 整点同步"
        if grep -q "$hour_marker" "$daily_file" 2>/dev/null; then
            info "本小时已同步，跳过"
        else
            # 追加本小时记录
            cat >> "$daily_file" << EOF

---

## 🕐 Hourly 层 - 实时记录

### ${hour}:00 - 整点同步
- **时间**：$timestamp
- **类型**：hourly_sync
- **任务**：$task_id
- **阶段**：$phase
- **Git 状态**：$git_summary
- **内容**：
  整点自动同步，记录当前状态
- **标签**：hourly, checkpoint, state

EOF
            success "已更新今日日志"
        fi
    fi

    # 更新心跳状态
    update_heartbeat_status "hourly"

    # 输出摘要
    echo ""
    echo "同步完成:"
    echo "  日志文件：$daily_file"
    echo "  下次同步：$(( (10#$hour + 1) % 24 )):00"
}

# 更新心跳状态
update_heartbeat_status() {
    local check_type="$1"
    local timestamp=$(date -Iseconds)

    local hourly_status=$(jq -r '.hourly.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")
    local daily_status=$(jq -r '.daily.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")
    local weekly_status=$(jq -r '.weekly.status // "unknown"' "$STATUS_FILE" 2>/dev/null || echo "unknown")

    case "$check_type" in
        hourly)
            hourly_status="ok"
            ;;
        daily)
            daily_status="ok"
            ;;
        weekly)
            weekly_status="ok"
            ;;
    esac

    cat > "$STATUS_FILE" << EOF
{
  "hourly": {
    "lastCheck": "$timestamp",
    "status": "$hourly_status"
  },
  "daily": {
    "lastCheck": "$(jq -r '.daily.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$daily_status"
  },
  "weekly": {
    "lastCheck": "$(jq -r '.weekly.lastCheck // "never"' "$STATUS_FILE" 2>/dev/null || echo $timestamp)",
    "status": "$weekly_status"
  }
}
EOF
}

# 检查并提醒未完成的事项
check_pending_items() {
    local daily_file=$(get_daily_file)

    if [ -f "$daily_file" ]; then
        local pending_count=$(grep -c "\[ \]" "$daily_file" 2>/dev/null || echo "0")
        if [ "$pending_count" -gt 0 ]; then
            warning "有 $pending_count 个待办事项未完成"
            echo ""
            echo "待办列表:"
            grep "\[ \]" "$daily_file" | sed 's/^/  /'
            echo ""
        fi
    fi
}

# 主函数
main() {
    case "${1:-sync}" in
        sync)
            sync_hourly
            check_pending_items
            ;;
        status)
            if [ -f "$STATUS_FILE" ]; then
                echo "心跳状态:"
                jq . "$STATUS_FILE"
            else
                info "暂无心跳记录"
            fi
            ;;
        -h|--help)
            cat << EOF
用法：$0 [命令]

命令:
  sync      执行 Hourly 同步（默认）
  status    查看心跳状态
  help      显示帮助

EOF
            ;;
        *)
            sync_hourly
            ;;
    esac
}

main "$@"
