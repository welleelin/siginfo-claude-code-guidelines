#!/bin/bash

# model-doctor.sh - 大模型渠道诊断脚本
# 检查所有大模型渠道的状态

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置文件目录
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
ACTIVE_MODEL_FILE="${CLAUDE_CONFIG_DIR}/active-model"
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

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║         🏥 大模型渠道状态诊断                    ║"
echo "╠════════════════════════════════════════════════╣"

# 获取当前模型
current_model=""
if [ -f "$ACTIVE_MODEL_FILE" ]; then
    current_model=$(cat "$ACTIVE_MODEL_FILE")
fi

# 检查每个渠道
for key in "${!MODELS[@]}"; do
    local model_id="${MODELS[$key]}"
    local status="${GREEN}✅${NC}"
    local status_text="正常"

    # 检查是否当前模型
    if [ "$model_id" = "$current_model" ]; then
        status="${GREEN}📌${NC}"
        status_text="当前"
    fi

    # 检查 API Key（非 Claude 模型）
    if [ "$key" != "opus" ] && [ "$key" != "sonnet" ] && [ "$key" != "haiku" ]; then
        if [ ! -f "${CREDENTIALS_DIR}/${key}" ]; then
            status="${YELLOW}⚠️${NC}"
            status_text="需配置 API Key"
        fi
    fi

    printf "%s %-15s %-30s [%s]\n" "$status" "$key" "$model_id" "$status_text"
done

echo "╠════════════════════════════════════════════════╣"
echo "║  ${GREEN}📌${NC} 当前模型    ${GREEN}✅${NC} 正常    ${YELLOW}⚠️${NC} 需配置            ║"
echo "╚════════════════════════════════════════════════╝"

# 检查配置文件
echo ""
echo "配置文件:"
echo "  配置目录：$CLAUDE_CONFIG_DIR"
echo "  当前模型：${current_model:-未设置}"
echo ""

# 提供建议
if [ -z "$current_model" ]; then
    echo "💡 建议：运行 './scripts/switch-model.sh sonnet' 设置默认模型"
fi
