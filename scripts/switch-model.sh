#!/bin/bash

# switch-model.sh - 大模型渠道切换脚本
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

# 配置文件目录
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ACTIVE_MODEL_FILE="${CLAUDE_CONFIG_DIR}/active-model"
CREDENTIALS_DIR="${CLAUDE_CONFIG_DIR}/credentials"
USAGE_FILE="${CLAUDE_CONFIG_DIR}/model-usage.yaml"

# 用量告警阈值
WARNING_THRESHOLD=70
CRITICAL_THRESHOLD=85
EMERGENCY_THRESHOLD=95

# 模型定义（函数方式，兼容 bash 3.2）
get_model_id() {
    case "$1" in
        opus) echo "claude-opus-4-20250514" ;;
        sonnet) echo "claude-sonnet-4-20250514" ;;
        haiku) echo "claude-3-5-haiku-20241022" ;;
        minimax) echo "minimax-text-01" ;;
        glm) echo "glm-4-plus" ;;
        qwen) echo "qwen3.5-plus" ;;
        deepseek) echo "deepseek-chat" ;;
        *) echo "" ;;
    esac
}

get_model_desc() {
    case "$1" in
        opus) echo "Claude Opus - 最强推理、架构设计" ;;
        sonnet) echo "Claude Sonnet - 主力开发、平衡性能" ;;
        haiku) echo "Claude Haiku - 快速任务、经济实惠" ;;
        minimax) echo "MiniMax - 中文内容生成" ;;
        glm) echo "GLM-4 - 中文理解、代码生成" ;;
        qwen) echo "Qwen - 多语言支持" ;;
        deepseek) echo "DeepSeek - 代码生成、数学推理" ;;
        *) echo "" ;;
    esac
}

get_model_cost() {
    case "$1" in
        opus) echo "4x" ;;
        sonnet) echo "1x" ;;
        haiku) echo "0.1x" ;;
        minimax) echo "0.5x" ;;
        glm) echo "0.8x" ;;
        qwen) echo "0.8x" ;;
        deepseek) echo "0.3x" ;;
        *) echo "?" ;;
    esac
}

get_model_level() {
    case "$1" in
        opus) echo "L1" ;;
        sonnet) echo "L2" ;;
        haiku) echo "L3" ;;
        minimax) echo "L3" ;;
        glm) echo "L2" ;;
        qwen) echo "L2" ;;
        deepseek) echo "L3" ;;
        *) echo "?" ;;
    esac
}

# 获取模型用量
get_model_usage() {
    local model_key="$1"
    local used=0 limit=10000000 remaining=10000000

    if [ -f "$USAGE_FILE" ]; then
        local val=$(grep -A5 "  ${model_key}:" "$USAGE_FILE" 2>/dev/null | grep "used:" | head -1 | awk '{print $2}')
        [ -n "$val" ] && used="$val"
        val=$(grep -A5 "  ${model_key}:" "$USAGE_FILE" 2>/dev/null | grep "limit:" | head -1 | awk '{print $2}')
        [ -n "$val" ] && limit="$val"
        val=$(grep -A5 "  ${model_key}:" "$USAGE_FILE" 2>/dev/null | grep "remaining:" | head -1 | awk '{print $2}')
        [ -n "$val" ] && remaining="$val"
    fi

    echo "${used}:${limit}:${remaining}"
}

calc_percentage() {
    local used="$1" limit="$2"
    [ "$limit" -gt 0 ] && echo $((used * 100 / limit)) || echo "0"
}

check_usage_alert() {
    local model_key="$1"
    local usage_data=$(get_model_usage "$model_key")
    IFS=':' read -r used limit remaining <<< "$usage_data"
    local pct=$(calc_percentage "$used" "$limit")

    if [ "$pct" -ge "$EMERGENCY_THRESHOLD" ]; then echo "3"
    elif [ "$pct" -ge "$CRITICAL_THRESHOLD" ]; then echo "2"
    elif [ "$pct" -ge "$WARNING_THRESHOLD" ]; then echo "1"
    else echo "0"
    fi
}

list_channels() {
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║         🤖 可用大模型渠道                       ║"
    echo "╠════════════════════════════════════════════════╣"

    local current_model=""
    [ -f "$ACTIVE_MODEL_FILE" ] && current_model=$(cat "$ACTIVE_MODEL_FILE")

    for key in opus sonnet haiku minimax glm qwen deepseek; do
        local model_id=$(get_model_id "$key")
        local desc=$(get_model_desc "$key")
        local cost=$(get_model_cost "$key")
        local level=$(get_model_level "$key")
        local marker="  "
        [ "$model_id" = "$current_model" ] && marker="${GREEN}>>${NC}"

        local api_status="${GREEN}✅${NC}"
        [ ! -f "${CREDENTIALS_DIR}/${key}" ] && api_status="${YELLOW}⚠️${NC}"

        printf "%s %-12s %-25s %s  成本:%-4s %s\n" "$marker" "$key" "$desc" "$level" "$cost" "$api_status"
    done

    echo "╠════════════════════════════════════════════════╣"
    echo "║  ${GREEN}✅${NC} 已配置    ${YELLOW}⚠️${NC} 需配置    ${GREEN}>>${NC} 当前模型          ║"
    echo "╚════════════════════════════════════════════════╝"
}

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
        warning "未找到当前模型配置"
    fi
}

show_usage() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    📊 大模型用量监控                                ║"
    echo "╠════════════════════════════════════════════════════════════════════╣"
    printf "║  %-15s %-8s %-20s %-20s ║\n" "模型" "级别" "已用 / 总额" "剩余"
    echo "╠════════════════════════════════════════════════════════════════════╣"

    for key in opus sonnet haiku minimax glm qwen deepseek; do
        local level=$(get_model_level "$key")
        local usage_data=$(get_model_usage "$key")
        IFS=':' read -r used limit remaining <<< "$usage_data"
        local pct=$(calc_percentage "$used" "$limit")

        local status="${GREEN}✅${NC}"
        [ "$pct" -ge "$EMERGENCY_THRESHOLD" ] && status="${RED}🚨${NC}"
        [ "$pct" -ge "$CRITICAL_THRESHOLD" ] && status="${RED}⚠️${NC}"
        [ "$pct" -ge "$WARNING_THRESHOLD" ] && status="${YELLOW}⚠️${NC}"

        printf "║ %s %-13s %-8s %8d / %-8d %8d (%3d%%)  ║\n" "$status" "$key" "$level" "$used" "$limit" "$remaining" "$pct"
    done
    echo "╚════════════════════════════════════════════════════════════════════╝"
}

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
    echo "╚════════════════════════════════════════════════╝"
}

recommend_model() {
    local task="$1"
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  📊 模型推荐                                    ║"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  任务：$task"
    echo "╠════════════════════════════════════════════════╣"

    local recommended="sonnet" reason="平衡性能和成本"
    case "$task" in
        *中文*|*写作*|*文案*|*博客*) recommended="minimax"; reason="中文内容生成优化" ;;
        *数学*|*推理*) recommended="deepseek"; reason="数学推理能力强" ;;
        *架构*|*设计*|*规划*) recommended="opus"; reason="深度推理最佳" ;;
    esac

    local rec_desc=$(get_model_desc "$recommended")
    local rec_usage=$(get_model_usage "$recommended")
    IFS=':' read -r used limit remaining <<< "$rec_usage"
    local pct=$(calc_percentage "$used" "$limit")

    echo "║  推荐：$recommended ($rec_desc)"
    echo "║  原因：$reason"
    printf "║  用量：%d%% (剩余：%d)\n" "$pct" "$remaining"
    echo "╚════════════════════════════════════════════════╝"
}

configure_api_key() {
    local model_key="$1"
    [ -z "$(get_model_id "$model_key")" ] && { error "未知的模型：$model_key"; exit 1; }

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║         🔐 配置 ${model_key} API Key"
    echo "╠════════════════════════════════════════════════╣"
    mkdir -p "$CREDENTIALS_DIR"
    echo "║  请输入 API Key:"
    echo "╚════════════════════════════════════════════════╝"
    echo -n "> "
    read -s api_key
    echo ""
    [ -z "$api_key" ] && { error "API Key 不能为空"; exit 1; }
    echo "$api_key" > "${CREDENTIALS_DIR}/${model_key}"
    chmod 600 "${CREDENTIALS_DIR}/${model_key}"
    success "API Key 已保存到 ${CREDENTIALS_DIR}/${model_key}"
}

switch_model() {
    local model_key="$1"
    local model_id=$(get_model_id "$model_key")

    [ -z "$model_id" ] && { error "未知的模型：$model_key"; echo "使用 --list 查看所有可用模型"; exit 1; }

    local desc=$(get_model_desc "$model_key")
    local cost=$(get_model_cost "$model_key")
    local level=$(get_model_level "$model_key")
    local current_model=""
    [ -f "$ACTIVE_MODEL_FILE" ] && current_model=$(cat "$ACTIVE_MODEL_FILE")

    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║          🔄 切换大模型渠道                      ║"
    echo "╠════════════════════════════════════════════════╣"
    printf "║  当前模型：%-35s  ║\n" "${current_model:-无}"
    printf "║  目标模型：%-35s  ║\n" "$model_id"
    echo "╠════════════════════════════════════════════════╣"

    # 检查 API Key
    if [ "$model_key" != "opus" ] && [ "$model_key" != "sonnet" ] && [ "$model_key" != "haiku" ]; then
        if [ ! -f "${CREDENTIALS_DIR}/${model_key}" ]; then
            echo "║  ⚠️  API Key 未配置                              ║"
            echo "║  请先配置 API Key: $0 --configure $model_key"
            echo "╚════════════════════════════════════════════════╝"
            exit 1
        fi
        echo "║  ${GREEN}✅${NC} API Key 已配置"
    else
        echo "║  ${GREEN}✅${NC} Claude 渠道 (已配置)"
    fi

    # 检查用量
    echo "╠════════════════════════════════════════════════╣"
    local alert_level=$(check_usage_alert "$model_key")
    local usage_data=$(get_model_usage "$model_key")
    IFS=':' read -r used limit remaining <<< "$usage_data"
    local pct=$(calc_percentage "$used" "$limit")

    printf "║  📊 用量：%d%% (%d / %d)\n" "$pct" "$used" "$limit"
    echo "╠════════════════════════════════════════════════╣"

    if [ "$alert_level" = "3" ]; then
        echo "║  ${RED}🚨 紧急告警：用量已达 ${pct}%${NC}"
        echo "║  💡 正在为您推荐可用模型..."

        local recommended=""
        for key in opus sonnet haiku minimax glm qwen deepseek; do
            if [ "$key" != "$model_key" ]; then
                local other_alert=$(check_usage_alert "$key")
                if [ "$other_alert" != "3" ] && [ "$other_alert" != "2" ]; then
                    recommended="$key"
                    break
                fi
            fi
        done

        if [ -n "$recommended" ]; then
            local rec_desc=$(get_model_desc "$recommended")
            local rec_usage=$(get_model_usage "$recommended")
            IFS=':' read -r r_used r_limit r_remaining <<< "$rec_usage"
            local r_pct=$(calc_percentage "$r_used" "$r_limit")

            echo "╠════════════════════════════════════════════════╣"
            echo "║  💡 推荐切换：$recommended ($rec_desc)"
            printf "║     用量：%d%% (剩余：%d)\n" "$r_pct" "$r_remaining"
            echo "╠════════════════════════════════════════════════╣"
            echo "║  是否切换到推荐模型？(y/N)"
            echo "╚════════════════════════════════════════════════╝"
            read -r confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                info "正在切换到 $recommended..."
                switch_model "$recommended"
                exit 0
            fi
        fi

        echo "╠════════════════════════════════════════════════╣"
        echo "║  是否继续切换到 $model_key？(y/N)"
        echo "╚════════════════════════════════════════════════╝"
        read -r confirm
        [[ ! $confirm =~ ^[Yy]$ ]] && { info "已取消切换"; exit 0; }

    elif [ "$alert_level" = "2" ]; then
        echo "║  ${RED}⚠️  严重告警：用量已达 ${pct}%${NC}"
    elif [ "$alert_level" = "1" ]; then
        echo "║  ${YELLOW}⚠️  警告：用量已达 ${pct}%${NC}"
    else
        echo "║  ${GREEN}✅${NC} 用量充足"
    fi

    # 更新配置
    mkdir -p "$CLAUDE_CONFIG_DIR"
    echo "$model_id" > "$ACTIVE_MODEL_FILE"

    echo "╠════════════════════════════════════════════════╣"
    echo "║  ${GREEN}✅${NC} 配置文件已更新"
    echo "║  ${GREEN}🎉${NC} 已切换到 $desc"
    echo "║  💰 成本提示：$cost"
    echo "╚════════════════════════════════════════════════╝"

    # 记录日志
    local log_file="${CLAUDE_CONFIG_DIR}/model-switch.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switched to $model_key ($model_id)" >> "$log_file"
}

usage() {
    echo "用法：$0 <模型名称> [选项]"
    echo ""
    echo "模型列表:"
    echo "  opus       Claude Opus - 最强推理、架构设计"
    echo "  sonnet     Claude Sonnet - 主力开发、平衡性能"
    echo "  haiku      Claude Haiku - 快速任务、经济实惠"
    echo "  minimax    MiniMax - 中文内容生成"
    echo "  glm        GLM-4 - 中文理解、代码生成"
    echo "  qwen       Qwen - 多语言支持"
    echo "  deepseek   DeepSeek - 代码生成、数学推理"
    echo ""
    echo "选项:"
    echo "  --list       列出所有可用渠道"
    echo "  --current    显示当前激活的模型"
    echo "  --usage      显示用量监控"
    echo "  --stats      显示使用统计"
    echo "  --recommend  根据任务推荐模型"
    echo "  --configure  配置指定渠道的 API Key"
    echo "  -h, --help   显示帮助"
}

main() {
    [ $# -eq 0 ] && { usage; exit 1; }

    case "$1" in
        --list|-l) list_channels ;;
        --current|-c) show_current ;;
        --usage|-u) show_usage ;;
        --stats|-s) show_stats ;;
        --recommend|-r) [ -z "$2" ] && { error "请提供任务描述"; exit 1; }; recommend_model "$2" ;;
        --configure|-C) [ -z "$2" ] && { error "请指定要配置的模型"; exit 1; }; configure_api_key "$2" ;;
        --help|-h) usage; exit 0 ;;
        --*) error "未知选项：$1"; usage; exit 1 ;;
        *) switch_model "$1" ;;
    esac
}

main "$@"
