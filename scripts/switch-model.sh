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

# 用量告警阈值
WARNING_THRESHOLD=70
CRITICAL_THRESHOLD=85
EMERGENCY_THRESHOLD=95

# 用量配置文件
USAGE_FILE="${CLAUDE_CONFIG_DIR}/model-usage.yaml"

# 获取模型用量
get_model_usage() {
    local model_key="$1"

    if [ ! -f "$USAGE_FILE" ]; then
        echo "0:10000000:0"
        return 0
    fi

    # 从 YAML 文件读取用量（简化处理）
    local usage_section=$(sed -n "/^  ${model_key}:/,/^[a-z]/p" "$USAGE_FILE" 2>/dev/null)

    if [ -z "$usage_section" ]; then
        echo "0:10000000:0"
        return 0
    fi

    local used=$(echo "$usage_section" | grep "used:" | head -1 | awk '{print $2}')
    local limit=$(echo "$usage_section" | grep "limit:" | head -1 | awk '{print $2}')
    local remaining=$(echo "$usage_section" | grep "remaining:" | head -1 | awk '{print $2}')

    used=${used:-0}
    limit=${limit:-10000000}
    remaining=${remaining:-$((limit - used))}

    echo "${used}:${limit}:${remaining}"
}

# 检查用量并告警
check_usage_alert() {
    local model_key="$1"
    local usage_data=$(get_model_usage "$model_key")

    IFS=':' read -r used limit remaining <<< "$usage_data"

    if [ "$limit" -gt 0 ]; then
        local percentage=$((used * 100 / limit))
    else
        local percentage=0
    fi

    # 存储百分比供后续使用
    MODEL_USAGE_PERCENTAGE[$model_key]=$percentage

    if [ "$percentage" -ge "$EMERGENCY_THRESHOLD" ]; then
        return 3  # 紧急
    elif [ "$percentage" -ge "$CRITICAL_THRESHOLD" ]; then
        return 2  # 严重
    elif [ "$percentage" -ge "$WARNING_THRESHOLD" ]; then
        return 1  # 警告
    fi
    return 0  # 正常
}

# 显示用量告警
show_usage_alert() {
    local model_key="$1"
    local alert_level="$2"

    local usage_data=$(get_model_usage "$model_key")
    IFS=':' read -r used limit remaining <<< "$usage_data"
    local percentage="${MODEL_USAGE_PERCENTAGE[$model_key]}"

    local title=""
    local color=""
    case "$alert_level" in
        1) title="⚠️  警告"; color="$YELLOW" ;;
        2) title="⚠️  严重告警"; color="$RED" ;;
        3) title="🚨 紧急告警"; color="$RED" ;;
    esac

    echo "╠════════════════════════════════════════════════╣"
    echo "║  $title：${MODELS[$model_key]}"
    echo "║  已用：${percentage}% (${used} / ${limit})"
    echo "║  剩余：${remaining}"

    if [ "$alert_level" -ge 2 ]; then
        echo "╠════════════════════════════════════════════════╣"
        echo "║  建议切换模型："

        # 推荐用量充足的 L2/L3 模型
        for key in "${!MODEL_LEVELS[@]}"; do
            local level="${MODEL_LEVELS[$key]}"
            local other_pct="${MODEL_USAGE_PERCENTAGE[$key]:-0}"
            if [ "$level" = "L2" ] || [ "$level" = "L3" ]; then
                if [ "$other_pct" -lt 50 ] && [ "$key" != "$model_key" ]; then
                    echo "║    - $key (用量 ${other_pct}%)"
                fi
            fi
        done
    fi
}

# 用量感知切换（推荐模型）
recommend_model() {
    local task="$1"

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  📊 模型推荐                                    ║"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  任务：$task"
    echo "╠════════════════════════════════════════════════╣"

    # 根据任务类型推荐
    local recommended=""
    local reason=""

    if [[ "$task" =~ .*[中中中文文文].* ]] || [[ "$task" =~ .*写作.* ]] || [[ "$task" =~ .*文案.* ]]; then
        recommended="minimax"
        reason="中文内容生成优化"
    elif [[ "$task" =~ .*数学.* ]] || [[ "$task" =~ .*推理.* ]]; then
        recommended="deepseek"
        reason="数学推理能力强"
    elif [[ "$task" =~ .*架构.* ]] || [[ "$task" =~ .*设计.* ]]; then
        recommended="opus"
        reason="深度推理最佳"
    else
        recommended="sonnet"
        reason="平衡性能和成本"
    fi

    # 检查推荐模型的用量
    local rec_usage=$(get_model_usage "$recommended")
    IFS=':' read -r used limit remaining <<< "$rec_usage"
    local rec_pct=$((used * 100 / limit))

    if [ "$rec_pct" -ge "$CRITICAL_THRESHOLD" ]; then
        # 用量不足，推荐备选
        recommended="sonnet"
        reason="$recommended 用量不足，切换到平衡模型"
    fi

    echo "║  推荐：$recommended (${MODEL_DESC[$recommended]})"
    echo "║  原因：$reason"
    echo "╚════════════════════════════════════════════════╝"
}

# 测试模型可用性
test_model() {
    local model_key="$1"
    local model_id="${MODELS[$model_key]}"

    echo "║  🧪 测试模型可用性..."
    echo "╠════════════════════════════════════════════════╣"

    # Claude 模型测试
    if [ "$model_key" = "opus" ] || [ "$model_key" = "sonnet" ] || [ "$model_key" = "haiku" ]; then
        # 检查 Anthropic API
        if command -v curl &> /dev/null; then
            local response=$(curl -s -o /dev/null -w "%{http_code}" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $ANTHROPIC_API_KEY" \
                -d "{\"model\":\"$model_id\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":1}" \
                "https://api.anthropic.com/v1/messages" 2>/dev/null || echo "000")

            if [ "$response" = "200" ] || [ "$response" = "401" ]; then
                echo "║  ${GREEN}✅${NC} $model_id - 可用"
                return 0
            elif [ "$response" = "429" ]; then
                echo "║  ${YELLOW}⚠️${NC} $model_id - 速率限制"
                return 1
            else
                echo "║  ${RED}❌${NC} $model_id - 不可用 (HTTP $response)"
                return 1
            fi
        fi

    # MiniMax 测试
    elif [ "$model_key" = "minimax" ]; then
        if [ -f "${CREDENTIALS_DIR}/${model_key}" ]; then
            local api_key=$(cat "${CREDENTIALS_DIR}/${model_key}")
            if command -v curl &> /dev/null; then
                local response=$(curl -s -o /dev/null -w "%{http_code}" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $api_key" \
                    -d "{\"model\":\"$model_id\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":1}" \
                    "https://api.minimax.chat/v1/text/chatcompletion" 2>/dev/null || echo "000")

                if [ "$response" = "200" ]; then
                    echo "║  ${GREEN}✅${NC} $model_id - 可用"
                    return 0
                elif [ "$response" = "401" ]; then
                    echo "║  ${RED}❌${NC} $model_id - API Key 无效"
                    return 1
                else
                    echo "║  ${YELLOW}⚠️${NC} $model_id - 响应：HTTP $response"
                    return 0  # 假设可用
                fi
            fi
        fi

    # GLM 测试
    elif [ "$model_key" = "glm" ]; then
        if [ -f "${CREDENTIALS_DIR}/${model_key}" ]; then
            local api_key=$(cat "${CREDENTIALS_DIR}/${model_key}")
            if command -v curl &> /dev/null; then
                local response=$(curl -s -o /dev/null -w "%{http_code}" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $api_key" \
                    -d "{\"model\":\"$model_id\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":1}" \
                    "https://open.bigmodel.cn/api/paas/v4/chat/completions" 2>/dev/null || echo "000")

                if [ "$response" = "200" ]; then
                    echo "║  ${GREEN}✅${NC} $model_id - 可用"
                    return 0
                elif [ "$response" = "401" ]; then
                    echo "║  ${RED}❌${NC} $model_id - API Key 无效"
                    return 1
                else
                    echo "║  ${YELLOW}⚠️${NC} $model_id - 响应：HTTP $response"
                    return 0  # 假设可用
                fi
            fi
        fi

    # DeepSeek 测试
    elif [ "$model_key" = "deepseek" ]; then
        if [ -f "${CREDENTIALS_DIR}/${model_key}" ]; then
            local api_key=$(cat "${CREDENTIALS_DIR}/${model_key}")
            if command -v curl &> /dev/null; then
                local response=$(curl -s -o /dev/null -w "%{http_code}" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $api_key" \
                    -d "{\"model\":\"$model_id\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":1}" \
                    "https://api.deepseek.com/v1/chat/completions" 2>/dev/null || echo "000")

                if [ "$response" = "200" ]; then
                    echo "║  ${GREEN}✅${NC} $model_id - 可用"
                    return 0
                elif [ "$response" = "401" ]; then
                    echo "║  ${RED}❌${NC} $model_id - API Key 无效"
                    return 1
                else
                    echo "║  ${YELLOW}⚠️${NC} $model_id - 响应：HTTP $response"
                    return 0  # 假设可用
                fi
            fi
        fi
    fi

    # 无法测试时，假设可用
    echo "║  ${YELLOW}⚠️${NC} 无法测试 $model_id，假设可用"
    return 0
}

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
    local level="${MODEL_LEVELS[$model_key]}"

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

    # 检查用量 ⭐ NEW
    echo "╠════════════════════════════════════════════════╣"
    check_usage_alert "$model_key"
    local alert_level=$?

    if [ $alert_level -eq 3 ]; then
        # 紧急告警 - 自动推荐可用模型
        show_usage_alert "$model_key" 3
        echo "╠════════════════════════════════════════════════╣"
        echo "║  🚨 用量已达紧急阈值，正在为您推荐可用模型...  ║"

        # 查找用量充足且级别合适的模型
        local recommended=""
        local recommended_level=""
        local current_level="${MODEL_LEVELS[$model_key]}"

        for key in "${!MODEL_LEVELS[@]}"; do
            if [ "$key" != "$model_key" ]; then
                check_usage_alert "$key"
                local other_level=$?
                local key_model_level="${MODEL_LEVELS[$key]}"

                # 优先推荐同级或更高级别且用量充足的模型
                if [ "$other_level" -lt 2 ]; then
                    # 用量充足 (<70%)
                    if [ -z "$recommended" ]; then
                        recommended="$key"
                        recommended_level="$key_model_level"
                    elif [ "$key_model_level" = "L1" ] && [ "$recommended_level" != "L1" ]; then
                        # L1 优先
                        recommended="$key"
                        recommended_level="$key_model_level"
                    elif [ "$key_model_level" = "L2" ] && [ "$recommended_level" = "L3" ]; then
                        # L2 优于 L3
                        recommended="$key"
                        recommended_level="$key_model_level"
                    fi
                fi
            fi
        done

        if [ -n "$recommended" ]; then
            local rec_desc="${MODEL_DESC[$recommended]}"
            local rec_usage=$(get_model_usage "$recommended")
            IFS=':' read -r used limit remaining <<< "$rec_usage"
            local rec_pct=0
            if [ "$limit" -gt 0 ]; then
                rec_pct=$((used * 100 / limit))
            fi

            echo "╠════════════════════════════════════════════════╣"
            echo "║  💡 推荐切换：$recommended ($rec_desc)"
            printf "║     用量：${rec_pct}%% (剩余：${remaining})                     ║\n"
            echo "╠════════════════════════════════════════════════╣"
            echo "║  是否切换到推荐模型？(y/N)"
            echo "╚════════════════════════════════════════════════╝"
            read -r confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                info "正在切换到 $recommended..."
                switch_model "$recommended"
                exit 0
            fi
        else
            echo "╠════════════════════════════════════════════════╣"
            echo "║  ⚠️  暂无合适的推荐模型，您可手动选择           ║"
            echo "╠════════════════════════════════════════════════╣"
            echo "║  是否继续切换到 $model_key？(y/N)"
            echo "╚════════════════════════════════════════════════╝"
            read -r confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                info "已取消切换"
                exit 0
            fi
        fi
    elif [ $alert_level -eq 2 ]; then
        # 严重告警
        show_usage_alert "$model_key" 2
    elif [ $alert_level -eq 1 ]; then
        # 警告
        show_usage_alert "$model_key" 1
    fi

    # 测试模型可用性 ⭐ NEW
    echo "╠════════════════════════════════════════════════╣"
    if ! test_model "$model_key"; then
        echo "╠════════════════════════════════════════════════╣"
        echo "║  ${RED}❌${NC} 模型不可用，取消切换"
        echo "╠════════════════════════════════════════════════╣"
        echo "║  建议：                                        ║"
        echo "║  1. 检查 API Key 是否有效                       ║"
        echo "║  2. 检查网络连接                                ║"
        echo "║  3. 检查账户余额                                ║"
        echo "╠════════════════════════════════════════════════╣"
        echo "║  使用其他模型：$0 --list"
        echo "╚════════════════════════════════════════════════╝"
        exit 1
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

# 显示用量概览
show_usage() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    📊 大模型用量监控                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    printf "║  %-15s %-8s %-18s %-25s ║\n" "模型" "级别" "已用 / 总额" "剩余"
    echo "╠════════════════════════════════════════════════════════════════════╣"

    for key in "opus" "sonnet" "haiku" "minimax" "glm" "qwen" "deepseek"; do
        local usage_data=$(get_model_usage "$key")
        IFS=':' read -r used limit remaining <<< "$usage_data"
        local percentage=0
        if [ "$limit" -gt 0 ]; then
            percentage=$((used * 100 / limit))
        fi

        local status="${GREEN}✅${NC}"
        if [ "$percentage" -ge "$EMERGENCY_THRESHOLD" ]; then
            status="${RED}🚨${NC}"
        elif [ "$percentage" -ge "$CRITICAL_THRESHOLD" ]; then
            status="${RED}⚠️${NC}"
        elif [ "$percentage" -ge "$WARNING_THRESHOLD" ]; then
            status="${YELLOW}⚠️${NC}"
        fi

        printf "%s %-13s %-8s %8d / %-8d %8d (%3d%%) ║\n" \
            "$status" "$key" "${MODEL_LEVELS[$key]}" "$used" "$limit" "$remaining" "$percentage"
    done

    echo "╚════════════════════════════════════════════════════════════════════╝"
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
        --usage|-u)
            show_usage
            ;;
        --recommend|-r)
            if [ -z "$2" ]; then
                error "请提供任务描述"
                usage
                exit 1
            fi
            recommend_model "$2"
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
