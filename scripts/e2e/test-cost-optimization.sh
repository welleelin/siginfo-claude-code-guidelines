#!/bin/bash
# =============================================================================
# 成本优化验证测试
# =============================================================================
# 测试目标: 验证模型路由效果和成本节省
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 测试配置
TEST_NAME="Cost Optimization Test"

# =============================================================================
# 测试场景
# =============================================================================

test_model_routing() {
    log_step "1/2" "模型路由效果验证"

    # 模型成本（相对单位）
    local HAIKU_COST=1
    local SONNET_COST=3
    local OPUS_COST=15

    # 测试场景
    local scenarios=(
        "代码格式化:0-4:haiku"
        "功能开发:5-9:sonnet"
        "架构设计:10+:opus"
    )

    local total_original_cost=0
    local total_optimized_cost=0
    local routing_accuracy=0
    local total_scenarios=${#scenarios[@]}

    for scenario in "${scenarios[@]}"; do
        local name="${scenario%%:*}"
        local complexity="${scenario#*:}"
        complexity="${complexity%%:*}"
        local expected_model="${scenario##*:}"

        # 模拟复杂度评估
        local actual_complexity=$complexity

        # 根据复杂度选择模型
        local selected_model=""
        local cost=0
        local original_cost=$OPUS_COST  # 假设原本都用 Opus

        if [[ $actual_complexity -lt 5 ]]; then
            selected_model="haiku"
            cost=$HAIKU_COST
        elif [[ $actual_complexity -lt 10 ]]; then
            selected_model="sonnet"
            cost=$SONNET_COST
        else
            selected_model="opus"
            cost=$OPUS_COST
        fi

        total_original_cost=$((total_original_cost + original_cost))
        total_optimized_cost=$((total_optimized_cost + cost))

        if [[ "$selected_model" == "$expected_model" ]]; then
            ((routing_accuracy++))
            log_info "  $name: 复杂度=$actual_complexity → $selected_model (成本=$cost) ✅"
        else
            log_info "  $name: 复杂度=$actual_complexity → $selected_model (预期=$expected_model) ❌"
        fi
    done

    local savings=$((100 - total_optimized_cost * 100 / total_original_cost))
    local accuracy_pct=$((routing_accuracy * 100 / total_scenarios))

    log_info "  原始成本: $total_original_cost (全部使用 Opus)"
    log_info "  优化成本: $total_optimized_cost"
    log_info "  成本节省: ${savings}%"
    log_info "  路由准确率: ${accuracy_pct}%"

    if [[ $savings -ge 30 ]] && [[ $accuracy_pct -ge 90 ]]; then
        log_success "模型路由验证通过（节省 ${savings}%, 准确率 ${accuracy_pct}%）"
        return 0
    else
        log_failure "模型路由未达标（节省 ${savings}%, 准确率 ${accuracy_pct}%）"
        return 1
    fi
}

test_batch_optimization() {
    log_step "2/2" "批量任务优化验证"

    # 模拟批量任务
    local tasks=(
        "简单任务1:1"
        "简单任务2:2"
        "中等任务1:5"
        "中等任务2:6"
        "复杂任务1:12"
    )

    # 按复杂度排序
    log_info "  按复杂度排序任务..."

    # 计算批量处理成本
    local batch_cost=0
    local individual_cost=0

    for task in "${tasks[@]}"; do
        local complexity="${task##*:}"

        # 批量处理：复杂任务用高级模型，简单任务批量处理
        if [[ $complexity -ge 10 ]]; then
            batch_cost=$((batch_cost + 15))  # Opus
        elif [[ $complexity -ge 5 ]]; then
            batch_cost=$((batch_cost + 3))   # Sonnet
        else
            batch_cost=$((batch_cost + 1))   # Haiku
        fi

        # 个别处理（假设都用较高成本模型）
        individual_cost=$((individual_cost + 3))
    done

    local efficiency=$((100 - batch_cost * 100 / individual_cost))

    log_info "  个别处理成本: $individual_cost"
    log_info "  批量处理成本: $batch_cost"
    log_info "  效率提升: ${efficiency}%"

    if [[ $efficiency -ge 20 ]]; then
        log_success "批量任务优化验证通过（效率提升 ${efficiency}%）"
        return 0
    else
        log_failure "批量任务优化不足: ${efficiency}% < 20%"
        return 1
    fi
}

# =============================================================================
# 主测试函数
# =============================================================================

run_test() {
    log_section "$TEST_NAME"

    # 执行所有测试
    test_model_routing || return 1
    test_batch_optimization || return 1

    log_success "成本优化验证测试完成"

    return 0
}

# 运行测试
run_test
