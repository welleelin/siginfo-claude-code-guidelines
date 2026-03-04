#!/bin/bash

# restore-state.sh - 状态恢复脚本
# 用于从检查点恢复项目和任务状态

set -e

# 配置
CHECKPOINT_DIR="${CHECKPOINT_DIR:-checkpoints}"
MEMORY_FILE="${MEMORY_FILE:-MEMORY.md}"

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
用法：$0 <检查点 ID> [选项]

选项:
  -l, --list          列出可用检查点
  -v, --verbose       显示详细信息
  -h, --help          显示帮助

示例:
  $0 --list                      # 列出所有检查点
  $0 state-20260304-120000       # 恢复到指定检查点
  $0 latest                      # 恢复到最近的检查点

EOF
}

# 列出检查点
list_checkpoints() {
    if [ ! -d "$CHECKPOINT_DIR" ] || [ -z "$(ls -A ${CHECKPOINT_DIR}/*.json 2>/dev/null)" ]; then
        info "暂无检查点"
        return 0
    fi

    echo "可用检查点:"
    echo "─────────────────────────────────────────────────────────────"
    printf "%-30s %-10s %-15s %-10s %s\n" "检查点 ID" "类型" "时间" "任务" "原因"
    echo "─────────────────────────────────────────────────────────────"

    for file in "${CHECKPOINT_DIR}"/*.json; do
        if [ -f "$file" ]; then
            local id=$(jq -r '.id' "$file" 2>/dev/null || echo "unknown")
            local type=$(jq -r '.type // "unknown"' "$file" 2>/dev/null)
            local time=$(jq -r '.timestamp' "$file" 2>/dev/null | cut -dT -f1,2 | tr T ' ')
            local task=$(jq -r '.task.id // "-"' "$file" 2>/dev/null)
            local reason=$(jq -r '.reason // "-"' "$file" 2>/dev/null)

            printf "%-30s %-10s %-15s %-10s %s\n" "$id" "$type" "$time" "$task" "$reason"
        fi
    done

    echo "─────────────────────────────────────────────────────────────"
}

# 查找最近的检查点
find_latest() {
    ls -t "${CHECKPOINT_DIR}"/*.json 2>/dev/null | head -1
}

# 查找指定检查点
find_checkpoint() {
    local checkpoint_id="$1"
    local checkpoint_file="${CHECKPOINT_DIR}/${checkpoint_id}.json"

    if [ ! -f "$checkpoint_file" ]; then
        # 尝试模糊匹配
        checkpoint_file=$(ls "${CHECKPOINT_DIR}/${checkpoint_id}"*.json 2>/dev/null | head -1)
    fi

    if [ -z "$checkpoint_file" ] || [ ! -f "$checkpoint_file" ]; then
        return 1
    fi

    echo "$checkpoint_file"
}

# 显示检查点详情
show_checkpoint_details() {
    local file="$1"

    echo "检查点详情:"
    echo "─────────────────────────────────────────────────────────────"

    local id=$(jq -r '.id' "$file")
    local time=$(jq -r '.timestamp' "$file")
    local type=$(jq -r '.type' "$file")
    local reason=$(jq -r '.reason' "$file")
    local task_id=$(jq -r '.task.id' "$file")
    local phase=$(jq -r '.task.phase' "$file")
    local branch=$(jq -r '.git.branch' "$file")
    local changes=$(jq -r '.git.changes' "$file")

    echo "  ID: $id"
    echo "  时间：$time"
    echo "  类型：$type"
    echo "  原因：$reason"
    echo ""
    echo "  任务：$task_id"
    echo "  阶段：$phase"
    echo ""
    echo "  Git 分支：$branch"
    echo "  更改：$changes"
    echo ""

    # 显示修改的文件
    local modified_count=$(jq -r '.files.modified | length' "$file")
    if [ "$modified_count" -gt 0 ]; then
        echo "  修改的文件 ($modified_count):"
        jq -r '.files.modified[]' "$file" | head -10 | sed 's/^/    /'
        if [ "$modified_count" -gt 10 ]; then
            echo "    ... 还有 $((modified_count - 10)) 个文件"
        fi
    fi

    echo "─────────────────────────────────────────────────────────────"
}

# 恢复状态
restore_state() {
    local checkpoint_id="$1"
    local verbose="${2:-false}"

    # 查找检查点文件
    local checkpoint_file
    if [ "$checkpoint_id" = "latest" ]; then
        checkpoint_file=$(find_latest)
        if [ -z "$checkpoint_file" ]; then
            error "未找到检查点"
            return 1
        fi
    else
        checkpoint_file=$(find_checkpoint "$checkpoint_id")
        if [ -z "$checkpoint_file" ]; then
            error "未找到检查点：$checkpoint_id"
            return 1
        fi
    fi

    # 显示详情
    if [ "$verbose" = "true" ]; then
        show_checkpoint_details "$checkpoint_file"
    fi

    # 解析检查点数据
    local task_id=$(jq -r '.task.id' "$checkpoint_file")
    local phase=$(jq -r '.task.phase' "$checkpoint_file")
    local branch=$(jq -r '.git.branch' "$checkpoint_file")
    local modified_files=$(jq -r '.files.modified[]' "$checkpoint_file" 2>/dev/null)

    warning "即将恢复状态"
    echo ""
    echo "  检查点：$(jq -r '.id' "$checkpoint_file")"
    echo "  任务：$task_id"
    echo "  阶段：$phase"
    echo "  分支：$branch"
    echo ""

    # 检查是否有未提交的更改
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$uncommitted" -gt 0 ]; then
        warning "检测到 $uncommitted 个未提交的更改"
        echo ""
        echo "请先提交或暂存更改，或运行："
        echo "  git stash"
        echo ""
        return 1
    fi

    # 提示确认
    echo "是否继续恢复？(y/N)"
    read -r confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "已取消恢复"
        return 0
    fi

    # 恢复建议
    info "恢复建议:"
    echo ""
    echo "1. 更新 MEMORY.md 中的任务状态:"
    echo "   - taskId: $task_id"
    echo "   - currentPhase: $phase"
    echo ""
    echo "2. 检查修改的文件:"
    for file in $modified_files; do
        if [ -f "$file" ]; then
            echo "   - $file (已修改)"
        else
            echo "   - $file (可能需要重新生成)"
        fi
    done
    echo ""

    echo "3. 查看检查点文件获取更多信息:"
    echo "   cat $checkpoint_file | jq"
    echo ""

    success "恢复指南已生成"
    echo ""
    echo "下一步操作:"
    echo "  1. 确认上述文件列表"
    echo "  2. 手动恢复关键文件（如需要）"
    echo "  3. 更新 MEMORY.md 状态"
    echo "  4. 继续任务执行"
}

# 主函数
main() {
    case "${1:-}" in
        -l|--list)
            list_checkpoints
            ;;
        -h|--help)
            usage
            ;;
        "")
            usage
            exit 1
            ;;
        *)
            local checkpoint_id="$1"
            local verbose=false

            shift
            while [[ $# -gt 0 ]]; do
                case $1 in
                    -v|--verbose)
                        verbose=true
                        ;;
                esac
                shift
            done

            restore_state "$checkpoint_id" "$verbose"
            ;;
    esac
}

main "$@"
