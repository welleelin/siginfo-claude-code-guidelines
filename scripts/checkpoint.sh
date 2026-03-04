#!/bin/bash

# checkpoint.sh - 检查点管理脚本
# 用于保存、恢复、列出和管理项目状态检查点

set -e

# 配置
CHECKPOINT_DIR="${CHECKPOINT_DIR:-checkpoints}"
MEMORY_FILE="${MEMORY_FILE:-MEMORY.md}"
GIT_REMOTE="${GIT_REMOTE:-origin}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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
用法：$0 <命令> [选项]

命令:
  start <task_id>     开始任务，创建检查点分支
  save [reason]       保存当前状态为检查点
  restore <id>        恢复到指定检查点
  list                列出所有检查点
  status [task_id]    查看任务状态
  complete <task_id>  完成任务，合并分支并打 tag
  rollback <task_id>  回滚任务到开始前状态

选项:
  -h, --help          显示帮助信息
  -v, --verbose       详细输出

示例:
  $0 start 52                    # 开始任务 52
  $0 save "完成需求分析"          # 保存检查点
  $0 list                        # 列出检查点
  $0 restore checkpoint-20260304-120000
  $0 complete 52                 # 完成任务 52
  $0 rollback 52                 # 回滚任务 52

EOF
}

# 确保检查点目录存在
ensure_checkpoint_dir() {
    if [ ! -d "$CHECKPOINT_DIR" ]; then
        mkdir -p "$CHECKPOINT_DIR"
        info "创建检查点目录：$CHECKPOINT_DIR"
    fi
}

# 获取当前 Git 分支
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# 获取当前 Git commit
get_current_commit() {
    git rev-parse HEAD
}

# 获取当前任务 ID（从 MEMORY.md 或环境变量）
get_task_id() {
    if [ -n "$TASK_ID" ]; then
        echo "$TASK_ID"
    elif [ -f "$MEMORY_FILE" ]; then
        grep -o '"taskId": "[^"]*"' "$MEMORY_FILE" 2>/dev/null | head -1 | cut -d'"' -f4 || echo "unknown"
    else
        echo "unknown"
    fi
}

# 获取当前阶段（从 MEMORY.md）
get_current_phase() {
    if [ -f "$MEMORY_FILE" ]; then
        grep -o '"currentPhase": "[^"]*"' "$MEMORY_FILE" 2>/dev/null | cut -d'"' -f4 || echo "unknown"
    else
        echo "unknown"
    fi
}

# 获取已修改文件列表
get_modified_files() {
    git diff --name-only 2>/dev/null || echo "[]"
}

# 获取未提交的更改统计
get_changes_stats() {
    local added=$(git diff --numstat 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
    local deleted=$(git diff --numstat 2>/dev/null | awk '{sum+=$2} END {print sum+0}')
    echo "+$added -$deleted"
}

# 保存状态快照
save_checkpoint() {
    local reason="${1:-manual}"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local checkpoint_id="checkpoint-${timestamp}"
    local checkpoint_file="${CHECKPOINT_DIR}/${checkpoint_id}.json"

    ensure_checkpoint_dir

    local task_id=$(get_task_id)
    local phase=$(get_current_phase)
    local branch=$(get_current_branch)
    local commit=$(get_current_commit)
    local changes=$(get_changes_stats)

    # 创建检查点 JSON
    cat > "$checkpoint_file" << EOF
{
  "id": "${checkpoint_id}",
  "timestamp": "$(date -Iseconds)",
  "reason": "${reason}",
  "task": {
    "id": "${task_id}",
    "phase": "${phase}"
  },
  "git": {
    "branch": "${branch}",
    "commit": "${commit}",
    "changes": "${changes}"
  },
  "files": {
    "modified": $(git diff --name-only 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo "[]"),
    "untracked": $(git ls-files --others --exclude-standard 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo "[]")
  },
  "memory": {
    "exists": $([ -f "$MEMORY_FILE" ] && echo "true" || echo "false"),
    "lastModified": "$([ -f "$MEMORY_FILE" ] && stat -f %m "$MEMORY_FILE" 2>/dev/null || stat -c %Y "$MEMORY_FILE" 2>/dev/null || echo "0")"
  },
  "recovery": {
    "branch": "${branch}",
    "canRestore": true
  }
}
EOF

    success "状态已保存到 $checkpoint_file"
    echo ""
    echo "检查点信息:"
    echo "  ID: ${checkpoint_id}"
    echo "  任务：${task_id}"
    echo "  阶段：${phase}"
    echo "  分支：${branch}"
    echo "  更改：${changes}"
}

# 列出所有检查点
list_checkpoints() {
    ensure_checkpoint_dir

    if [ ! -f "${CHECKPOINT_DIR}/checkpoint-000000-000000.json" ] 2>/dev/null && [ -z "$(ls -A ${CHECKPOINT_DIR}/*.json 2>/dev/null)" ]; then
        info "暂无检查点"
        return 0
    fi

    echo "检查点列表:"
    echo "─────────────────────────────────────────────────────────────"
    printf "%-25s %-10s %-15s %-10s %s\n" "ID" "任务" "时间" "阶段" "原因"
    echo "─────────────────────────────────────────────────────────────"

    for file in "${CHECKPOINT_DIR}"/*.json; do
        if [ -f "$file" ]; then
            local id=$(jq -r '.id' "$file" 2>/dev/null || echo "unknown")
            local task=$(jq -r '.task.id' "$file" 2>/dev/null || echo "-")
            local time=$(jq -r '.timestamp' "$file" 2>/dev/null | cut -dT -f1,2 | tr T ' ')
            local phase=$(jq -r '.task.phase' "$file" 2>/dev/null || echo "-")
            local reason=$(jq -r '.reason' "$file" 2>/dev/null || echo "-")

            printf "%-25s %-10s %-15s %-10s %s\n" "$id" "$task" "$time" "$phase" "$reason"
        fi
    done

    echo "─────────────────────────────────────────────────────────────"
}

# 恢复到指定检查点
restore_checkpoint() {
    local checkpoint_id="$1"
    local checkpoint_file="${CHECKPOINT_DIR}/${checkpoint_id}.json"

    if [ ! -f "$checkpoint_file" ]; then
        # 尝试模糊匹配
        checkpoint_file=$(ls "${CHECKPOINT_DIR}/${checkpoint_id}"*.json 2>/dev/null | head -1)
        if [ -z "$checkpoint_file" ] || [ ! -f "$checkpoint_file" ]; then
            error "检查点不存在：$checkpoint_id"
            return 1
        fi
    fi

    local branch=$(jq -r '.recovery.branch' "$checkpoint_file")
    local commit=$(jq -r '.git.commit' "$checkpoint_file")
    local task_id=$(jq -r '.task.id' "$checkpoint_file")

    warning "即将恢复到检查点：$checkpoint_id"
    echo "  分支：$branch"
    echo "  Commit: $commit"
    echo "  任务：$task_id"
    echo ""

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        warning "检测到未提交的更改，请先提交或暂存"
        return 1
    fi

    # 恢复 Git 状态
    info "恢复 Git 状态..."
    git checkout "$branch" 2>/dev/null || git checkout -b "$branch"
    git reset --hard "$commit"

    success "已恢复到检查点：$checkpoint_id"
    echo ""
    echo "下一步操作:"
    echo "  1. 检查恢复状态：git status"
    echo "  2. 查看修改文件：git diff --name-only"
    echo "  3. 继续任务：修改代码后运行 '\$0 save'"
}

# 开始任务
start_task() {
    local task_id="$1"
    local branch_name="task/${task_id}"

    info "开始任务：$task_id"

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        warning "检测到未提交的更改，请先提交或暂存"
        return 1
    fi

    # 创建任务分支
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        warning "任务分支已存在：$branch_name"
        git checkout "$branch_name"
    else
        info "创建任务分支：$branch_name"
        git checkout -b "$branch_name"
    fi

    # 创建初始检查点
    save_checkpoint "start_task_${task_id}"

    # 创建 before 检查点（用于回滚）
    local before_file="${CHECKPOINT_DIR}/before-task-${task_id}.json"
    cat > "$before_file" << EOF
{
  "id": "before-task-${task_id}",
  "timestamp": "$(date -Iseconds)",
  "type": "before_task",
  "task": {
    "id": "${task_id}"
  },
  "git": {
    "branch": "$(get_current_branch)",
    "commit": "$(get_current_commit)"
  },
  "recovery": {
    "canRollback": true
  }
}
EOF

    success "任务 $task_id 已启动"
    echo ""
    echo "分支：$branch_name"
    echo "初始检查点已创建"
    echo ""
    echo "下一步:"
    echo "  1. 更新 MEMORY.md 中的任务状态"
    echo "  2. 开始执行任务"
    echo "  3. 关键节点运行 '\$0 save <原因>'"
}

# 完成任务
complete_task() {
    local task_id="$1"
    local branch_name="task/${task_id}"
    local current_branch=$(get_current_branch)

    info "完成任务：$task_id"

    # 检查是否在任务分支上
    if [ "$current_branch" != "$branch_name" ]; then
        warning "当前不在任务分支上，切换到 $branch_name"
        git checkout "$branch_name" || return 1
    fi

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        info "检测到未提交的更改，将一并提交"
    fi

    # 创建完成检查点
    save_checkpoint "complete_task_${task_id}"

    # 打 tag
    local tag_name="task-${task_id}-completed-$(date +%Y%m%d-%H%M%S)"
    git add -A
    git commit -m "chore: 完成任务 $task_id" 2>/dev/null || true
    git tag "$tag_name"

    success "任务 $task_id 已完成"
    echo ""
    echo "Tag: $tag_name"
    echo ""
    echo "下一步:"
    echo "  1. 合并到主分支：git checkout main && git merge $branch_name"
    echo "  2. 或删除任务分支：git branch -d $branch_name"
}

# 回滚任务
rollback_task() {
    local task_id="$1"
    local before_file="${CHECKPOINT_DIR}/before-task-${task_id}.json"
    local branch_name="task/${task_id}"

    if [ ! -f "$before_file" ]; then
        error "未找到任务回滚点：$before_file"
        return 1
    fi

    local commit=$(jq -r '.git.commit' "$before_file")

    warning "即将回滚任务 $task_id"
    echo "  Commit: $commit"
    echo ""

    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        warning "检测到未提交的更改，请先提交或暂存"
        return 1
    fi

    # 切换到任务分支
    git checkout "$branch_name" 2>/dev/null || return 1

    # 回滚
    git reset --hard "$commit"

    # 删除任务分支
    git checkout main
    git branch -D "$branch_name"

    success "任务 $task_id 已回滚"
}

# 查看任务状态
task_status() {
    local task_id="${1:-$(get_task_id)}"
    local branch_name="task/${task_id}"

    echo "任务状态：$task_id"
    echo "─────────────────────────────────────────────────────────────"

    # 检查任务分支是否存在
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        echo "  分支：$branch_name (存在)"

        # 统计提交数
        local commits=$(git rev-list --count "$branch_name"..HEAD 2>/dev/null || echo "0")
        echo "  提交数：$commits"
    else
        echo "  分支：$branch_name (不存在)"
    fi

    # 检查检查点
    local checkpoint_count=$(ls "${CHECKPOINT_DIR}/"*"${task_id}"*.json 2>/dev/null | wc -l)
    echo "  检查点数：$checkpoint_count"

    # 显示最近检查点
    local latest=$(ls -t "${CHECKPOINT_DIR}/"*"${task_id}"*.json 2>/dev/null | head -1)
    if [ -n "$latest" ] && [ -f "$latest" ]; then
        local time=$(jq -r '.timestamp' "$latest" 2>/dev/null | cut -dT -f1,2 | tr T ' ')
        local reason=$(jq -r '.reason' "$latest" 2>/dev/null)
        echo "  最近检查点：$time - $reason"
    fi

    echo "─────────────────────────────────────────────────────────────"
}

# 主函数
main() {
    case "${1:-}" in
        start)
            [ -z "$2" ] && { error "请提供任务 ID"; usage; exit 1; }
            start_task "$2"
            ;;
        save)
            save_checkpoint "${2:-manual}"
            ;;
        restore)
            [ -z "$2" ] && { error "请提供检查点 ID"; usage; exit 1; }
            restore_checkpoint "$2"
            ;;
        list)
            list_checkpoints
            ;;
        status)
            task_status "${2:-}"
            ;;
        complete)
            [ -z "$2" ] && { error "请提供任务 ID"; usage; exit 1; }
            complete_task "$2"
            ;;
        rollback)
            [ -z "$2" ] && { error "请提供任务 ID"; usage; exit 1; }
            rollback_task "$2"
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
