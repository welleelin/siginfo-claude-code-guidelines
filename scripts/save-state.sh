#!/bin/bash

# save-state.sh - 状态保存脚本
# 用于保存当前项目和任务状态快照

set -e

# 配置
CHECKPOINT_DIR="${CHECKPOINT_DIR:-checkpoints}"
MEMORY_FILE="${MEMORY_FILE:-MEMORY.md}"
MEMORY_DIR="${MEMORY_DIR:-memory}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# 显示使用说明
usage() {
    cat << EOF
用法：$0 [选项] [原因]

选项:
  -a, --auto          自动模式（用于定时任务）
  -r, --reason <文本> 保存原因
  -h, --help          显示帮助

示例:
  $0                           # 手动保存
  $0 -r "完成需求分析"          # 指定保存原因
  $0 -a                        # 自动模式（用于 hourly sync）

EOF
}

# 确保目录存在
ensure_dirs() {
    mkdir -p "$CHECKPOINT_DIR"
    mkdir -p "$MEMORY_DIR"
}

# 获取当前任务 ID
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

# 获取当前步骤
get_current_step() {
    if [ -f "$MEMORY_FILE" ]; then
        grep -o '"currentStep": "[^"]*"' "$MEMORY_FILE" 2>/dev/null | cut -d'"' -f4 || echo "unknown"
    else
        echo "unknown"
    fi
}

# 获取 Git 状态
get_git_status() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")
    local commit=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
    local changes=$(git diff --numstat 2>/dev/null | awk '{added+=$1; deleted+=$2} END {printf "+%d -%d", added+0, deleted+0}')
    local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    echo "{\"branch\": \"$branch\", \"commit\": \"$commit\", \"changes\": \"$changes\", \"uncommitted\": $status}"
}

# 获取已修改文件
get_modified_files() {
    git diff --name-only 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo "[]"
}

# 获取未跟踪文件
get_untracked_files() {
    git ls-files --others --exclude-standard 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo "[]"
}

# 保存状态快照
save_state() {
    local reason="${1:-manual}"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local iso_timestamp=$(date -Iseconds)
    local checkpoint_id="state-${timestamp}"
    local checkpoint_file="${CHECKPOINT_DIR}/${checkpoint_id}.json"

    ensure_dirs

    local task_id=$(get_task_id)
    local phase=$(get_current_phase)
    local step=$(get_current_step)
    local git_status=$(get_git_status)
    local modified_files=$(get_modified_files)
    local untracked_files=$(get_untracked_files)

    # 创建状态 JSON
    cat > "$checkpoint_file" << EOF
{
  "id": "${checkpoint_id}",
  "timestamp": "${iso_timestamp}",
  "type": "state_snapshot",
  "reason": "${reason}",
  "task": {
    "id": "${task_id}",
    "phase": "${phase}",
    "step": "${step}"
  },
  "git": ${git_status},
  "files": {
    "modified": ${modified_files},
    "untracked": ${untracked_files}
  },
  "memory": {
    "file": "${MEMORY_FILE}",
    "exists": $([ -f "$MEMORY_FILE" ] && echo "true" || echo "false"),
    "dailyLog": "${MEMORY_DIR}/$(date +%Y-%m-%d).md",
    "dailyLogExists": $([ -f "${MEMORY_DIR}/$(date +%Y-%m-%d).md" ] && echo "true" || echo "false")
  },
  "context": {
    "sessionId": "${SESSION_ID:-unknown}",
    "hostname": "$(hostname)"
  }
}
EOF

    # 同时更新今日日志
    update_daily_log "$reason"

    success "状态已保存到 $checkpoint_file"
    echo ""
    echo "状态摘要:"
    echo "  任务：${task_id}"
    echo "  阶段：${phase}"
    echo "  步骤：${step}"
    echo "  Git: $(echo $git_status | jq -r '.changes')"
}

# 更新今日日志
update_daily_log() {
    local reason="$1"
    local today=$(date +%Y-%m-%d)
    local daily_file="${MEMORY_DIR}/${today}.md"
    local time=$(date +%H:%M)

    if [ ! -f "$daily_file" ]; then
        # 创建新日志
        cat > "$daily_file" << EOF
# 记忆日志 - ${today}

> 创建时间：$(date -Iseconds)
> 状态：active

---

## 📋 今日任务

| 任务 ID | 任务标题 | 状态 | 进度 | 备注 |
|--------|---------|------|------|------|
| $(get_task_id) | - | in_progress | 0% | - |

---

##  Hourly 层 - 实时记录

### ${time} - 状态保存
- **类型**：state_snapshot
- **内容**：${reason}
- **标签**：checkpoint, state

---

## ✅ 今日完成

- [ ] 待更新

---

## 🔄 待办事项

- [ ] 待更新

---
EOF
        info "创建今日日志：$daily_file"
    else
        # 追加到现有日志
        local timestamp_line="### ${time} - 状态保存"
        if ! grep -q "$timestamp_line" "$daily_file" 2>/dev/null; then
            cat >> "$daily_file" << EOF

---

##  Hourly 层 - 实时记录

### ${time} - 状态保存
- **类型**：state_snapshot
- **内容**：${reason}
- **标签**：checkpoint, state

EOF
            info "更新今日日志：$daily_file"
        fi
    fi
}

# 自动保存（用于定时任务）
auto_save() {
    local reason="auto_hourly_$(date +%H)"
    save_state "$reason"
}

# 主函数
main() {
    local reason="manual"
    local auto_mode=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--auto)
                auto_mode=true
                shift
                ;;
            -r|--reason)
                reason="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                reason="$1"
                shift
                ;;
        esac
    done

    if [ "$auto_mode" = true ]; then
        auto_save
    else
        save_state "$reason"
    fi
}

main "$@"
