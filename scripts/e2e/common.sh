#!/bin/bash
# =============================================================================
# E2E 测试通用函数库
# =============================================================================
# 版本: 1.0.0
# 用途: 提供 E2E 测试的通用辅助函数
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# 日志函数
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

log_step() {
    local step=$1
    local desc=$2
    echo ""
    echo -e "${BLUE}▶ Step $step:${NC} $desc"
}

log_section() {
    echo ""
    echo "───────────────────────────────────────────────────────────────────"
    echo -e "${BLUE}  $1${NC}"
    echo "───────────────────────────────────────────────────────────────────"
}

# =============================================================================
# 辅助函数
# =============================================================================

# 评估任务复杂度（0-15 分制）
assess_task_complexity() {
    local task="$1"
    local complexity=0

    # 基于关键词评估复杂度
    # 简单任务关键词
    if echo "$task" | grep -qiE "简单|修复|小|单个|简单版"; then
        complexity=1
    # 中等任务关键词
    elif echo "$task" | grep -qiE "功能|模块|实现|开发"; then
        complexity=5
    # 复杂任务关键词
    elif echo "$task" | grep -qiE "系统|架构|完整|企业|大型|多人"; then
        complexity=12
    else
        complexity=3  # 默认中等偏低
    fi

    echo $complexity
}

# 检查命令是否存在
check_command() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查文件是否存在
check_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        return 0
    else
        return 1
    fi
}

# 检查目录是否存在
check_dir() {
    local dir=$1
    if [[ -d "$dir" ]]; then
        return 0
    else
        return 1
    fi
}

# 生成随机字符串
generate_random_string() {
    local length=${1:-8}
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1
}

# 获取当前时间戳
get_timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

# 计算时间差（秒）
calculate_duration() {
    local start=$1
    local end=$2
    echo $((end - start))
}

# 格式化时间（秒转可读格式）
format_duration() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local secs=$((seconds % 60))

    if [[ $minutes -gt 0 ]]; then
        echo "${minutes}分${secs}秒"
    else
        echo "${secs}秒"
    fi
}

# =============================================================================
# 验证函数
# =============================================================================

# 验证 JSON 格式
validate_json() {
    local json="$1"
    if echo "$json" | jq . &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 验证百分比范围
validate_percentage() {
    local value=$1
    if [[ $value -ge 0 ]] && [[ $value -le 100 ]]; then
        return 0
    else
        return 1
    fi
}

# 验证测试覆盖率
validate_coverage() {
    local coverage=$1
    local min_coverage=${2:-80}

    if [[ $coverage -ge $min_coverage ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# 模拟函数（用于测试）
# =============================================================================

# 模拟 Claude CLI 调用
mock_claude_call() {
    local command=$1
    echo "Mock: claude $command"
    return 0
}

# 模拟 Agent 调用
mock_agent_call() {
    local agent=$1
    local task=$2
    echo "Mock: Agent $agent - Task: $task"
    return 0
}

# 模拟质量门禁检查
mock_quality_gate() {
    local gate=$1
    echo "Mock: Quality Gate $gate - PASSED"
    return 0
}
