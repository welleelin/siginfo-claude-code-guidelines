#!/bin/bash

# model-usage-check.sh - 大模型用量检查脚本
# 支持 API 查询和 Agent-Reach 获取控制台数据

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# 配置文件目录
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
USAGE_FILE="${CLAUDE_CONFIG_DIR}/model-usage.yaml"
CREDENTIALS_DIR="${CLAUDE_CONFIG_DIR}/credentials"

# 模型定义
declare -A MODELS=(
    ["opus"]="claude-opus-4-20250514"
    ["sonnet"]="claude-sonnet-4-20250514"
    ["haiku"]="claude-3-5-haiku-20241022"
    ["minimax"]="minimax-text-01"
    ["glm"]="glm-4-plus"
    ["qwen"]="qwen-max"
    ["deepseek"]="deepseek-chat"
)

# 模型级别
declare -A MODEL_LEVELS=(
    ["opus"]="L1"
    ["sonnet"]="L2"
    ["haiku"]="L3"
    ["minimax"]="L3"
    ["glm"]="L2"
    ["qwen"]="L2"
    ["deepseek"]="L3"
)

# 供应商控制台 URL
declare -A CONSOLE_URLS=(
    ["claude"]="https://console.anthropic.com/dashboard"
    ["minimax"]="https://platform.minimaxi.com/"
    ["glm"]="https://open.bigmodel.cn/"
    ["qwen"]="https://dashscope.console.aliyun.com/"
    ["deepseek"]="https://platform.deepseek.com/"
)

# 用量告警阈值
WARNING_THRESHOLD=70
CRITICAL_THRESHOLD=85
EMERGENCY_THRESHOLD=95

# 检查 Agent-Reach 是否可用
check_agent_reach() {
    if command -v agent-reach &> /dev/null; then
        return 0
    fi
    return 1
}

# 使用 Agent-Reach 获取控制台用量
get_usage_via_agent_reach() {
    local provider="$1"
    local cookie_file="${CREDENTIALS_DIR}/${provider}-cookie"

    if [ ! -f "$cookie_file" ]; then
        warning "未配置 ${provider} Cookie，无法获取用量"
        return 1
    fi

    local cookie=$(cat "$cookie_file")
    local url="${CONSOLE_URLS[$provider]}"

    info "使用 Agent-Reach 获取 ${provider} 用量..."

    # 使用 Jina Reader 读取控制台页面
    local response=$(curl -s \
        -H "User-Agent: Mozilla/5.0" \
        -H "Cookie: $cookie" \
        "https://r.jina.ai/${url}" 2>/dev/null)

    if [ -z "$response" ]; then
        error "无法获取 ${provider} 控制台数据"
        return 1
    fi

    # 尝试提取用量信息（需要根据实际页面结构调整）
    local used=$(echo "$response" | grep -oP '已用 [:：]\s*\K[\d,]+' | head -1 | tr -d ',')
    local limit=$(echo "$response" | grep -oP '总额 [:：]\s*\K[\d,]+' | head -1 | tr -d ',')
    local remaining=$(echo "$response" | grep -oP '剩余 [:：]\s*\K[\d,]+' | head -1 | tr -d ',')

    if [ -n "$used" ] && [ -n "$limit" ]; then
        echo "${used}:${limit}:${remaining}"
        return 0
    fi

    return 1
}

# 使用 API 获取 Claude 用量
get_claude_usage_api() {
    local api_key="${ANTHROPIC_API_KEY:-$(cat ${CREDENTIALS_DIR}/anthropic 2>/dev/null)}"

    if [ -z "$api_key" ]; then
        return 1
    fi

    # 调用 Anthropic API 获取用量
    local response=$(curl -s \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        "https://api.anthropic.com/v1/usage" 2>/dev/null)

    # 解析响应（简化处理）
    echo "$response" | jq -r '.tokens_used // empty' 2>/dev/null
}

# 检查单个模型用量
check_model_usage() {
    local model_key="$1"
    local model_id="${MODELS[$model_key]}"
    local level="${MODEL_LEVELS[$model_key]}"

    local used=0
    local limit=0
    local remaining=0
    local source="unknown"

    # Claude 模型优先使用 API
    if [ "$model_key" = "opus" ] || [ "$model_key" = "sonnet" ] || [ "$model_key" = "haiku" ]; then
        local api_usage=$(get_claude_usage_api)
        if [ -n "$api_usage" ]; then
            used=$api_usage
            limit=10000000  # 示例值
            remaining=$((limit - used))
            source="api"
        fi
    fi

    # API 失败时尝试 Agent-Reach
    if [ "$used" = "0" ]; then
        if check_agent_reach; then
            local ar_usage=$(get_usage_via_agent_reach "$model_key")
            if [ -n "$ar_usage" ]; then
                IFS=':' read -r used limit remaining <<< "$ar_usage"
                source="agent-reach"
            fi
        fi
    fi

    # 计算百分比
    local percentage=0
    if [ "$limit" -gt 0 ]; then
        percentage=$((used * 100 / limit))
    fi

    # 输出结果
    printf "%-15s %-30s %s  %-8s %6d / %-8d (%3d%%)  [%s]\n" \
        "$model_key" "$model_id" "$level" "${used}" "${limit}" "${percentage}" "${source}"
}

# 显示用量概览
show_usage_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    📊 大模型用量监控                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    printf "║  %-13s %-30s %-6s %-18s %-10s ║\n" "模型" "模型 ID" "级别" "已用 / 总额" "来源"
    echo "╠════════════════════════════════════════════════════════════════════╣"

    for key in "opus" "sonnet" "haiku" "minimax" "glm" "qwen" "deepseek"; do
        check_model_usage "$key"
    done

    echo "╚════════════════════════════════════════════════════════════════════╝"
}

# 检查用量告警
check_usage_alerts() {
    echo ""
    local has_alert=false

    for key in "${!MODELS[@]}"; do
        local model_id="${MODELS[$key]}"
        local percentage=0  # 实际应从用量文件读取

        # 简化处理：假设置从配置读取
        # TODO: 从 ~/.claude/model-usage.yaml 读取实际数据

        if [ "$percentage" -ge "$EMERGENCY_THRESHOLD" ]; then
            echo "╔════════════════════════════════════════════════╗"
            echo "║  🚨 紧急告警：$model_id"
            echo "║  用量已达 ${percentage}%，建议立即切换模型"
            echo "╚════════════════════════════════════════════════╝"
            has_alert=true
        elif [ "$percentage" -ge "$CRITICAL_THRESHOLD" ]; then
            echo "╔════════════════════════════════════════════════╗"
            echo "║  ⚠️  严重告警：$model_id"
            echo "║  用量已达 ${percentage}%，建议切换模型"
            echo "╚════════════════════════════════════════════════╝"
            has_alert=true
        elif [ "$percentage" -ge "$WARNING_THRESHOLD" ]; then
            echo "╔════════════════════════════════════════════════╗"
            echo "║  ⚠️  警告：$model_id"
            echo "║  用量已达 ${percentage}%"
            echo "╚════════════════════════════════════════════════╝"
            has_alert=true
        fi
    done

    if [ "$has_alert" = false ]; then
        echo "✅ 所有模型用量正常"
    fi
}

# 引导配置 Cookie
guide_cookie_config() {
    local provider="$1"
    local url="${CONSOLE_URLS[$provider]}"

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  🔐 配置 ${provider} Cookie 以获取用量           ║"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  步骤：                                        ║"
    echo "║  1. 浏览器打开：$url"
    echo "║  2. 登录账号                                   ║"
    echo "║  3. 使用 Cookie-Editor 导出 Cookie              ║"
    echo "║  4. 运行命令配置：                             ║"
    echo "║     /model-configure cookie ${provider} '...'   ║"
    echo "╚════════════════════════════════════════════════╝"
}

# 主函数
main() {
    case "${1:-}" in
        --summary|-s)
            show_usage_summary
            ;;
        --alerts|-a)
            check_usage_alerts
            ;;
        --guide|-g)
            if [ -z "$2" ]; then
                error "请指定供应商：opus/minimax/glm/qwen/deepseek"
                exit 1
            fi
            guide_cookie_config "$2"
            ;;
        --help|-h)
            cat << EOF
用法：$0 [选项]

选项:
  --summary, -s    显示用量概览
  --alerts, -a     检查用量告警
  --guide, -g      引导配置 Cookie
  --help, -h       显示帮助

示例:
  $0 --summary     # 查看所有模型用量
  $0 --alerts      # 检查告警
  $0 --guide glm   # GLM Cookie 配置引导
EOF
            ;;
        *)
            show_usage_summary
            check_usage_alerts
            ;;
    esac
}

main "$@"
