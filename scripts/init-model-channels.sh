#!/bin/bash

# init-model-channels.sh - 大模型渠道初始化脚本
# 通过交互方式配置用户已拥有的供应商信息

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

question() {
    echo -e "${CYAN}[?]${NC} $1"
}

# 配置文件目录
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CREDENTIALS_DIR="${CLAUDE_CONFIG_DIR}/credentials"
CHANNELS_FILE="${CLAUDE_CONFIG_DIR}/model-channels.yaml"
USAGE_FILE="${CLAUDE_CONFIG_DIR}/model-usage.yaml"

# 供应商列表
declare -A PROVIDERS=(
    ["claude"]="Claude (Anthropic) - 国际"
    ["codex"]="Codex (OpenAI) - 国际"
    ["gemini"]="Gemini (Google) - 国际"
    ["qwen"]="Qwen (阿里云) - 国内"
    ["glm"]="GLM (智谱 AI) - 国内"
    ["minimax"]="MiniMax (迷你 AI) - 国内"
    ["deepseek"]="DeepSeek (深度求索) - 国内"
)

# 推荐模型
declare -A RECOMMENDED_MODELS=(
    ["claude"]="claude-sonnet-4-20250514"
    ["codex"]="gpt-4o"
    ["gemini"]="gemini-2.0-pro"
    ["qwen"]="qwen-max"
    ["glm"]="glm-4-plus"
    ["minimax"]="minimax-text-01"
    ["deepseek"]="deepseek-chat"
)

# 供应商控制台 URL
declare -A CONSOLE_URLS=(
    ["claude"]="https://console.anthropic.com/"
    ["codex"]="https://platform.openai.com/"
    ["gemini"]="https://aistudio.google.com/"
    ["qwen"]="https://dashscope.console.aliyun.com/"
    ["glm"]="https://open.bigmodel.cn/"
    ["minimax"]="https://platform.minimaxi.com/"
    ["deepseek"]="https://platform.deepseek.com/"
)

# 显示欢迎信息
show_welcome() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║              🤖 大模型渠道初始化向导                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  本向导将帮助您配置已拥有的大模型供应商信息                         ║"
    echo "║  配置完成后，您可以随时切换使用不同的模型                           ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
}

# 显示供应商分类
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
    echo ""
}

# 选择供应商
select_providers() {
    echo -n "${CYAN}请输入您的选择：${NC}"
    read -r selection

    SELECTED_PROVIDERS=()

    if [ "$selection" = "all" ]; then
        SELECTED_PROVIDERS=("claude" "codex" "gemini" "qwen" "glm" "minimax" "deepseek")
        return
    fi

    IFS=',' read -ra selections <<< "$selection"
    for sel in "${selections[@]}"; do
        case "$sel" in
            1) SELECTED_PROVIDERS+=("claude") ;;
            2) SELECTED_PROVIDERS+=("codex") ;;
            3) SELECTED_PROVIDERS+=("gemini") ;;
            4) SELECTED_PROVIDERS+=("qwen") ;;
            5) SELECTED_PROVIDERS+=("glm") ;;
            6) SELECTED_PROVIDERS+=("minimax") ;;
            7) SELECTED_PROVIDERS+=("deepseek") ;;
            *) warning "无效选择：$sel" ;;
        esac
    done

    if [ ${#SELECTED_PROVIDERS[@]} -eq 0 ]; then
        error "未选择任何供应商，请重新选择"
        select_providers
    fi
}

# 配置单个供应商
configure_provider() {
    local provider="$1"
    local display_name="${PROVIDERS[$provider]}"
    local console_url="${CONSOLE_URLS[$provider]}"

    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║  配置 ${display_name}"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  请选择配置方式：                                                   ║"
    echo "║    [1] 已有 API Key                                                ║"
    echo "║    [2] 需要配置 Cookie (通过 Agent-Reach 获取用量)                  ║"
    echo "║    [3] 跳过                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "${CYAN}请选择 (1/2/3): ${NC}"
    read -r config_type

    case "$config_type" in
        1)
            # 配置 API Key
            echo ""
            echo "╔════════════════════════════════════════════════════════════════════╗"
            echo "║  💡 获取 API Key 步骤："
            echo "╠════════════════════════════════════════════════════════════════════╣"
            echo "║  1. 访问控制台：$console_url"
            echo "║  2. 登录账号"
            echo "║  3. 在 API 设置中创建 API Key"
            echo "║  4. 复制 API Key 到此处"
            echo "╚════════════════════════════════════════════════════════════════════╝"
            echo ""
            echo -n "${CYAN}请输入 API Key: ${NC}"
            read -s api_key
            echo ""

            if [ -n "$api_key" ]; then
                mkdir -p "$CREDENTIALS_DIR"
                echo "$api_key" > "${CREDENTIALS_DIR}/${provider}"
                chmod 600 "${CREDENTIALS_DIR}/${provider}"
                success "${provider} API Key 已配置"

                # 配置用量限额
                echo ""
                echo -n "${CYAN}请输入用量限额 (tokens, 默认 10000000): ${NC}"
                read -r limit
                limit=${limit:-10000000}

                # 更新用量配置文件
                update_usage_config "$provider" "$limit"
            fi
            ;;
        2)
            # 配置 Cookie
            echo ""
            echo "╔════════════════════════════════════════════════════════════════════╗"
            echo "║  💡 获取 Cookie 步骤："
            echo "╠════════════════════════════════════════════════════════════════════╣"
            echo "║  1. 访问控制台：$console_url"
            echo "║  2. 登录账号"
            echo "║  3. 安装 Chrome 插件 Cookie-Editor"
            echo "║  4. 点击 Cookie-Editor，导出 Cookie 字符串"
            echo "║  5. 复制 Cookie 到此处"
            echo "╚════════════════════════════════════════════════════════════════════╝"
            echo ""
            echo -n "${CYAN}请输入 Cookie: ${NC}"
            read -s cookie
            echo ""

            if [ -n "$cookie" ]; then
                mkdir -p "$CREDENTIALS_DIR"
                echo "$cookie" > "${CREDENTIALS_DIR}/${provider}-cookie"
                chmod 600 "${CREDENTIALS_DIR}/${provider}-cookie"
                success "${provider} Cookie 已配置"

                # 标记使用 Agent-Reach 获取用量
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

# 更新用量配置文件
update_usage_config() {
    local provider="$1"
    local limit="$2"
    local source="${3:-api}"
    local model_id="${RECOMMENDED_MODELS[$provider]}"

    # 创建或更新用量配置文件
    if [ ! -f "$USAGE_FILE" ]; then
        cat > "$USAGE_FILE" << EOF
# 大模型用量配置
last_updated: $(date -Iseconds)

channels:
EOF
    fi

    # 添加供应商配置（简化 YAML 格式）
    cat >> "$USAGE_FILE" << EOF
  ${provider}:
    model_id: ${model_id}
    level: L2
    usage:
      type: token
      used: 0
      limit: ${limit}
      remaining: ${limit}
      reset_date: $(date -d "+30 days" +%Y-%m-%d 2>/dev/null || date -v+30d +%Y-%m-%d)
      percentage: 0%
    source: ${source}
EOF
}

# 显示配置摘要
show_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    📋 配置摘要                                      ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"

    for provider in "${SELECTED_PROVIDERS[@]}"; do
        local has_api_key="❌"
        local has_cookie="❌"

        if [ -f "${CREDENTIALS_DIR}/${provider}" ]; then
            has_api_key="✅"
        fi
        if [ -f "${CREDENTIALS_DIR}/${provider}-cookie" ]; then
            has_cookie="✅"
        fi

        printf "║  %-12s  API Key: %-5s  Cookie: %-5s                          ║\n" \
            "$provider" "$has_api_key" "$has_cookie"
    done

    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  配置文件位置：                                                     ║"
    echo "║    - 凭据目录：${CREDENTIALS_DIR}"
    echo "║    - 用量配置：${USAGE_FILE}"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

# 显示后续步骤
show_next_steps() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    ✅ 配置完成！                                    ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  可用命令：                                                         ║"
    echo "║    /switch-model --list      # 查看所有可用渠道                     ║"
    echo "║    /switch-model --usage     # 查看用量监控                         ║"
    echo "║    /switch-model opus        # 切换到指定模型                       ║"
    echo "║    /switch-model --recommend \"任务\" # 根据任务推荐模型           ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    echo "║  下一步建议：                                                       ║"
    echo "║    1. 运行 /switch-model --usage 检查用量配置                       ║"
    echo "║    2. 开始您的任务，系统会自动推荐合适的模型                        ║"
    echo "║    3. 需要时手动切换模型：/switch-model <模型>                      ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

# 主函数
main() {
    show_welcome
    show_provider_categories
    select_providers

    info "已选择的供应商：${SELECTED_PROVIDERS[*]}"
    echo ""

    # 配置每个供应商
    for provider in "${SELECTED_PROVIDERS[@]}"; do
        configure_provider "$provider"
    done

    # 显示摘要
    show_summary
    show_next_steps

    # 创建目录结构
    mkdir -p "$CLAUDE_CONFIG_DIR"
    mkdir -p "$CREDENTIALS_DIR"

    success "配置完成！"
}

main "$@"
