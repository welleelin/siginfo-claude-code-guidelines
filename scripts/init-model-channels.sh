#!/bin/bash

# init-model-channels.sh - 大模型渠道初始化脚本
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
question() { echo -e "${CYAN}[?]${NC} $1"; }

CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CREDENTIALS_DIR="${CLAUDE_CONFIG_DIR}/credentials"
USAGE_FILE="${CLAUDE_CONFIG_DIR}/model-usage.yaml"

# 供应商显示名
get_provider_name() {
    case "$1" in
        claude) echo "Claude (Anthropic) - 国际" ;;
        codex) echo "Codex/GPT (OpenAI) - 国际" ;;
        gemini) echo "Gemini (Google) - 国际" ;;
        qwen) echo "Qwen/通义千问 (阿里云) - 国内" ;;
        glm) echo "GLM/智谱清言 (智谱 AI) - 国内" ;;
        minimax) echo "MiniMax/海螺 AI (迷你 AI) - 国内" ;;
        deepseek) echo "DeepSeek/深度求索 - 国内" ;;
        *) echo "$1" ;;
    esac
}

# 控制台 URL
get_console_url() {
    case "$1" in
        claude) echo "https://console.anthropic.com/" ;;
        codex) echo "https://platform.openai.com/" ;;
        gemini) echo "https://aistudio.google.com/" ;;
        qwen) echo "https://dashscope.console.aliyun.com/" ;;
        glm) echo "https://open.bigmodel.cn/" ;;
        minimax) echo "https://platform.minimaxi.com/" ;;
        deepseek) echo "https://platform.deepseek.com/" ;;
        *) echo "" ;;
    esac
}

# 推荐模型 ID
get_model_id() {
    case "$1" in
        claude) echo "claude-sonnet-4-20250514" ;;
        codex) echo "gpt-4o" ;;
        gemini) echo "gemini-2.0-pro" ;;
        qwen) echo "qwen-max" ;;
        glm) echo "glm-4-plus" ;;
        minimax) echo "minimax-text-01" ;;
        deepseek) echo "deepseek-chat" ;;
        *) echo "" ;;
    esac
}

show_welcome() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║              🤖 大模型渠道初始化向导                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  本向导将帮助您配置已拥有的大模型供应商信息                         ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

show_provider_categories() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║  请选择您已拥有的供应商（可多选，用逗号分隔）                       ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  【国际】                                                          ║"
    echo "║    [1] claude  - Claude (Anthropic)                                ║"
    echo "║    [2] codex   - Codex/GPT (OpenAI)                                ║"
    echo "║    [3] gemini  - Gemini (Google)                                   ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  【国内】                                                          ║"
    echo "║    [4] qwen    - Qwen/通义千问 (阿里云)                            ║"
    echo "║    [5] glm     - GLM/智谱清言 (智谱 AI)                            ║"
    echo "║    [6] minimax - MiniMax/海螺 AI (迷你 AI)                         ║"
    echo "║    [7] deepseek - DeepSeek/深度求索                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  输入示例：1,4,5  或 all (全选)                                    ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

select_providers() {
    echo ""
    echo -n "${CYAN}请输入您的选择：${NC}"
    read -r selection

    SELECTED_PROVIDERS=""

    if [ "$selection" = "all" ]; then
        SELECTED_PROVIDERS="claude codex gemini qwen glm minimax deepseek"
        return
    fi

    IFS=',' read -ra selections <<< "$selection"
    for sel in "${selections[@]}"; do
        case "$sel" in
            1) SELECTED_PROVIDERS="$SELECTED_PROVIDERS claude" ;;
            2) SELECTED_PROVIDERS="$SELECTED_PROVIDERS codex" ;;
            3) SELECTED_PROVIDERS="$SELECTED_PROVIDERS gemini" ;;
            4) SELECTED_PROVIDERS="$SELECTED_PROVIDERS qwen" ;;
            5) SELECTED_PROVIDERS="$SELECTED_PROVIDERS glm" ;;
            6) SELECTED_PROVIDERS="$SELECTED_PROVIDERS minimax" ;;
            7) SELECTED_PROVIDERS="$SELECTED_PROVIDERS deepseek" ;;
            *) warning "无效选择：$sel" ;;
        esac
    done

    if [ -z "$SELECTED_PROVIDERS" ]; then
        error "未选择任何供应商"
        select_providers
    fi
}

configure_provider() {
    local provider="$1"
    local display_name=$(get_provider_name "$1")
    local console_url=$(get_console_url "$1")

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  配置 ${display_name}"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  请选择配置方式：                               ║"
    echo "║    [1] 已有 API Key                            ║"
    echo "║    [2] 需要配置 Cookie (Agent-Reach 获取用量)   ║"
    echo "║    [3] 跳过                                    ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    echo -n "${CYAN}请选择 (1/2/3): ${NC}"
    read -r config_type

    case "$config_type" in
        1)
            echo ""
            echo "╔════════════════════════════════════════════════╗"
            echo "║  💡 获取 API Key 步骤："
            echo "║  1. 访问：$console_url"
            echo "║  2. 登录账号 → API 设置 → 创建 API Key"
            echo "╚════════════════════════════════════════════════╝"
            echo ""
            echo -n "${CYAN}请输入 API Key: ${NC}"
            read -s api_key
            echo ""

            if [ -n "$api_key" ]; then
                mkdir -p "$CREDENTIALS_DIR"
                echo "$api_key" > "${CREDENTIALS_DIR}/${provider}"
                chmod 600 "${CREDENTIALS_DIR}/${provider}"
                success "${provider} API Key 已配置"

                echo ""
                echo -n "${CYAN}用量限额 (tokens, 默认 10000000): ${NC}"
                read -r limit
                limit=${limit:-10000000}
                update_usage_config "$provider" "$limit" "api"
            fi
            ;;
        2)
            echo ""
            echo "╔════════════════════════════════════════════════╗"
            echo "║  💡 获取 Cookie 步骤："
            echo "║  1. 访问：$console_url"
            echo "║  2. 登录账号"
            echo "║  3. 使用 Cookie-Editor 导出 Cookie"
            echo "╚════════════════════════════════════════════════╝"
            echo ""
            echo -n "${CYAN}请输入 Cookie: ${NC}"
            read -s cookie
            echo ""

            if [ -n "$cookie" ]; then
                mkdir -p "$CREDENTIALS_DIR"
                echo "$cookie" > "${CREDENTIALS_DIR}/${provider}-cookie"
                chmod 600 "${CREDENTIALS_DIR}/${provider}-cookie"
                success "${provider} Cookie 已配置"
                update_usage_config "$provider" "0" "agent-reach"
            fi
            ;;
        3)
            warning "已跳过 ${provider}"
            ;;
        *)
            error "无效选择"
            ;;
    esac
}

update_usage_config() {
    local provider="$1"
    local limit="$2"
    local source="${3:-api}"
    local model_id=$(get_model_id "$provider")

    if [ ! -f "$USAGE_FILE" ]; then
        cat > "$USAGE_FILE" << EOF
# 大模型用量配置
last_updated: $(date -Iseconds 2>/dev/null || date +%Y-%m-%d)

channels:
EOF
    fi

    cat >> "$USAGE_FILE" << EOF
  ${provider}:
    model_id: ${model_id}
    level: L2
    usage:
      type: token
      used: 0
      limit: ${limit}
      remaining: ${limit}
      percentage: 0%
    source: ${source}
EOF
}

show_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    📋 配置摘要                                      ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"

    for provider in $SELECTED_PROVIDERS; do
        local has_api_key="❌"
        local has_cookie="❌"
        [ -f "${CREDENTIALS_DIR}/${provider}" ] && has_api_key="✅"
        [ -f "${CREDENTIALS_DIR}/${provider}-cookie" ] && has_cookie="✅"

        printf "║  %-12s  API Key: %-5s  Cookie: %-5s                        ║\n" "$provider" "$has_api_key" "$has_cookie"
    done

    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  配置文件位置：                                                     ║"
    echo "║    - 凭据目录：${CREDENTIALS_DIR}"
    echo "║    - 用量配置：${USAGE_FILE}"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

show_next_steps() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    ✅ 配置完成！                                    ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  可用命令：                                                         ║"
    echo "║    ./scripts/switch-model.sh --list       # 查看所有渠道            ║"
    echo "║    ./scripts/switch-model.sh --usage      # 查看用量监控            ║"
    echo "║    ./scripts/switch-model.sh opus         # 切换到 Opus             ║"
    echo "║    ./scripts/switch-model.sh sonnet       # 切换到 Sonnet           ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

# 主函数
main() {
    show_welcome
    show_provider_categories
    select_providers

    info "已选择的供应商：$SELECTED_PROVIDERS"

    for provider in $SELECTED_PROVIDERS; do
        configure_provider "$provider"
    done

    mkdir -p "$CLAUDE_CONFIG_DIR"
    mkdir -p "$CREDENTIALS_DIR"

    show_summary
    show_next_steps
    success "配置完成！"
}

main "$@"
