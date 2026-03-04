#!/bin/bash

# switch-model.sh - 大模型渠道切换脚本
# 用于快速切换不同的大模型渠道

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
ACTIVE_MODEL_FILE="${CLAUDE_CONFIG_DIR}/active-model"
CHANNELS_FILE="${CLAUDE_CONFIG_DIR}/model-channels.yaml"
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

# 模型描述
declare -A MODEL_DESC=(
    ["opus"]="Claude Opus - 最强推理、架构设计"
    ["sonnet"]="Claude Sonnet - 主力开发、平衡性能"
    ["haiku"]="Claude Haiku - 快速任务、经济实惠"
    ["minimax"]="MiniMax - 中文内容生成"
    ["glm"]="GLM-4 - 中文理解、代码生成"
    ["qwen"]="Qwen - 多语言支持"
    ["deepseek"]="DeepSeek - 代码生成、数学推理"
)

# 模型成本倍数
declare -A MODEL_COST=(
    ["opus"]="4x"
    ["sonnet"]="1x"
    ["haiku"]="0.1x"
    ["minimax"]="0.5x"
    ["glm"]="0.8x"
    ["qwen"]="0.8x"
    ["deepseek"]="0.3x"
)

# 显示使用说明
usage() {
    cat << EOF
用法：$0 <模型名称> [选项]

模型列表:
  opus       Claude Opus - 最强推理、架构设计
  sonnet     Claude Sonnet - 主力开发、平衡性能
  haiku      Claude Haiku - 快速任务、经济实惠
  minimax    MiniMax - 中文内容生成
  glm        GLM-4 - 中文理解、代码生成
  qwen       Qwen - 多语言支持
  deepseek   DeepSeek - 代码生成、数学推理

选项:
  --list       列出所有可用渠道
  --current    显示当前激活的模型
  --stats      显示使用统计
  --configure  配置指定渠道的 API Key
  -h, --help   显示帮助

示例:
  $0 opus                  # 切换到 Claude Opus
  $0 haiku                 # 切换到 Claude Haiku
  $0 --list                # 列出所有渠道
  $0 --current             # 查看当前模型
  $0 --stats               # 查看使用统计
  $0 --configure minimax   # 配置 MiniMax

快捷命令:
  /opus      /sonnet     /haiku
  /minimax   /glm        /qwen       /deepseek
EOF
}

# 列出所有可用渠道
list_channels() {
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║         🤖 可用大模型渠道                       ║"
    echo "╠════════════════════════════════════════════════╣"

    local current_model=""
    if [ -f "$ACTIVE_MODEL_FILE" ]; then
        current_model=$(cat "$ACTIVE_MODEL_FILE")
    fi

    for key in "${!MODELS[@]}"; do
        local model_id="${MODELS[$key]}"
        local desc="${MODEL_DESC[$key]}"
        local cost="${MODEL_COST[$key]}"
        local marker="  "

        if [ "$model_id" = "$current_model" ]; then
            marker="${GREEN}>>${NC}"
        fi

        # 检查 API Key 是否配置
        local api_status="${GREEN}✅${NC}"
        if [ "$key" != "opus" ] && [ "$key" != "sonnet" ] && [ "$key" != "haiku" ]; then
            if [ ! -f "${CREDENTIALS_DIR}/${key}" ]; then
                api_status="${YELLOW}⚠️${NC}"
            fi
        fi

        printf "%s %-12s %-30s 成本:%-4s %s\n" "$marker" "$key" "$desc" "$cost" "$api_status"
    done

    echo "╠════════════════════════════════════════════════╣"
    echo "║  ${GREEN}✅${NC} 已配置 API Key    ${YELLOW}⚠️${NC} 需配置 API Key          ║"
    echo "╚════════════════════════════════════════════════╝"
}

# 显示当前模型
show_current() {
    echo ""
    if [ -f "$ACTIVE_MODEL_FILE" ]; then
        local current_model=$(cat "$ACTIVE_MODEL_FILE")
        echo "╔════════════════════════════════════════════════╗"
        echo "║         📌 当前激活的大模型                     ║"
        echo "╠════════════════════════════════════════════════╣"
        echo "║  $current_model"
        echo "╚════════════════════════════════════════════════╝"
    else
        warning "未找到当前模型配置，请先切换模型"
    fi
}

# 切换模型
switch_model() {
    local model_key="$1"

    # 验证模型名称
    if [ -z "${MODELS[$model_key]}" ]; then
        error "未知的模型：$model_key"
        echo ""
        echo "使用 --list 查看所有可用模型"
        exit 1
    fi

    local model_id="${MODELS[$model_key]}"
    local desc="${MODEL_DESC[$model_key]}"
    local cost="${MODEL_COST[$model_key]}"

    # 获取当前模型
    local current_model=""
    if [ -f "$ACTIVE_MODEL_FILE" ]; then
        current_model=$(cat "$ACTIVE_MODEL_FILE")
    fi

    # 显示切换信息
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║          🔄 切换大模型渠道                      ║"
    echo "╠════════════════════════════════════════════════╣"
    printf "║  当前模型：%-35s  ║\n" "${current_model:-无}"
    printf "║  目标模型：%-35s  ║\n" "$model_id"
    echo "╠════════════════════════════════════════════════╣"

    # 检查 API Key（非 Claude 模型）
    if [ "$model_key" != "opus" ] && [ "$model_key" != "sonnet" ] && [ "$model_key" != "haiku" ]; then
        if [ ! -f "${CREDENTIALS_DIR}/${model_key}" ]; then
            echo "║  ⚠️  API Key 未配置                              ║"
            echo "╠════════════════════════════════════════════════╣"
            echo "║  请先配置 API Key:                              ║"
            echo "║  $0 --configure $model_key"
            echo "╚════════════════════════════════════════════════╝"
            exit 1
        fi
        echo "║  ${GREEN}✅${NC} API Key 已配置"
    else
        echo "║  ${GREEN}✅${NC} Claude 渠道 (已配置)"
    fi

    # 更新配置文件
    mkdir -p "$CLAUDE_CONFIG_DIR"
    echo "$model_id" > "$ACTIVE_MODEL_FILE"

    echo "║  ${GREEN}✅${NC} 配置文件已更新"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  ${GREEN}🎉${NC} 已切换到 $desc"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  💰 成本提示：$cost"
    echo "║  💡 建议：复杂任务完成后切回 Sonnet"
    echo "╚════════════════════════════════════════════════╝"

    # 记录切换日志
    log_switch "$model_key" "$model_id"
}

# 记录切换日志
log_switch() {
    local log_file="${CLAUDE_CONFIG_DIR}/model-switch.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Switched to $1 ($2)" >> "$log_file"
}

# 配置 API Key
configure_api_key() {
    local model_key="$1"

    if [ -z "${MODELS[$model_key]}" ]; then
        error "未知的模型：$model_key"
        exit 1
    fi

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║         🔐 配置 ${model_key} API Key                  ║"
    echo "╠════════════════════════════════════════════════╣"

    mkdir -p "$CREDENTIALS_DIR"

    echo "║  请输入 API Key:"
    echo "╚════════════════════════════════════════════════╝"
    echo -n "> "

    # 隐藏输入
    read -s api_key
    echo ""

    if [ -z "$api_key" ]; then
        error "API Key 不能为空"
        exit 1
    fi

    # 保存 API Key
    echo "$api_key" > "${CREDENTIALS_DIR}/${model_key}"
    chmod 600 "${CREDENTIALS_DIR}/${model_key}"

    success "API Key 已保存到 ${CREDENTIALS_DIR}/${model_key}"
}

# 显示使用统计
show_stats() {
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║       📊 大模型使用统计 (今日)                  ║"
    echo "╠════════════════════════════════════════════════╣"

    local log_file="${CLAUDE_CONFIG_DIR}/model-switch.log"
    local today=$(date '+%Y-%m-%d')

    if [ -f "$log_file" ]; then
        local count=$(grep "$today" "$log_file" | wc -l)
        echo "║  今日切换次数：$count"
    else
        echo "║  暂无使用记录"
    fi

    echo "╠════════════════════════════════════════════════╣"
    echo "║  💡 提示：详细统计需要集成 API 使用量追踪"
    echo "╚════════════════════════════════════════════════╝"
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    case "$1" in
        --list|-l)
            list_channels
            ;;
        --current|-c)
            show_current
            ;;
        --stats|-s)
            show_stats
            ;;
        --configure|-C)
            if [ -z "$2" ]; then
                error "请指定要配置的模型"
                usage
                exit 1
            fi
            configure_api_key "$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --*)
            error "未知选项：$1"
            usage
            exit 1
            ;;
        *)
            switch_model "$1"
            ;;
    esac
}

main "$@"
