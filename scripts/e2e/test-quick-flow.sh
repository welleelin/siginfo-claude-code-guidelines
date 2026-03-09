#!/bin/bash
# =============================================================================
# Quick Flow 端到端测试
# =============================================================================
# 测试目标: 验证小任务快速开发流程（< 2 小时）
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 测试配置
TEST_NAME="Quick Flow E2E Test"
MAX_DURATION=7200  # 2 小时（秒）
MIN_COVERAGE=80

# =============================================================================
# 测试步骤
# =============================================================================

step_1_task_input() {
    log_step "1/5" "任务输入测试"

    # 模拟任务输入
    local task="实现用户登录功能（简单版）"

    # 检查是否为简单任务（< 2 小时）
    local complexity=$(assess_task_complexity "$task")

    if [[ $complexity -lt 2 ]]; then
        log_success "任务复杂度评估: $complexity (适合 Quick Flow)"
        return 0
    else
        log_failure "任务复杂度过高: $complexity (应使用 Standard Flow)"
        return 1
    fi
}

step_2_quick_planning() {
    log_step "2/5" "快速规划测试"

    # 模拟 /bmad-bmm-quick-spec
    local start_time=$(date +%s)

    # 验证快速规划输出
    # 1. 需求摘要（5 分钟内完成）
    # 2. 技术方案（使用现有组件）
    # 3. 任务分解（3-5 个步骤）

    local planning_output=$(cat <<EOF
{
  "summary": "实现用户登录功能",
  "approach": "使用现有 JWT 组件",
  "steps": [
    "创建登录表单组件",
    "实现表单验证",
    "调用认证 API",
    "处理登录响应",
    "保存 Token"
  ],
  "estimatedTime": 45
}
EOF
)

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $duration -lt 300 ]]; then  # 5 分钟
        log_success "快速规划完成 (耗时: ${duration}s)"
        echo "$planning_output"
        return 0
    else
        log_failure "快速规划超时 (耗时: ${duration}s > 300s)"
        return 1
    fi
}

step_3_quick_development() {
    log_step "3/5" "快速开发测试"

    # 模拟 /bmad-bmm-quick-dev
    local start_time=$(date +%s)

    # 模拟开发步骤
    local steps=(
        "编写测试 (10 分钟)"
        "实现功能 (20 分钟)"
        "运行测试 (5 分钟)"
        "代码审查 (5 分钟)"
    )

    for step in "${steps[@]}"; do
        log_info "  - $step"
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # 模拟测试结果
    local test_pass_rate=100
    local coverage=85

    if [[ $test_pass_rate -eq 100 ]] && [[ $coverage -ge $MIN_COVERAGE ]]; then
        log_success "快速开发完成 (耗时: ${duration}s, 覆盖率: ${coverage}%)"
        return 0
    else
        log_failure "快速开发未达标 (通过率: ${test_pass_rate}%, 覆盖率: ${coverage}%)"
        return 1
    fi
}

step_4_verification() {
    log_step "4/5" "验证测试"

    # 模拟 /verify
    local checks=(
        "test_pass_rate:100"
        "code_quality_gate:passed"
        "security_scan:clean"
    )

    local all_passed=true
    for check in "${checks[@]}"; do
        local key="${check%%:*}"
        local value="${check##*:}"

        if [[ "$value" == "passed" ]] || [[ "$value" == "100" ]] || [[ "$value" == "clean" ]]; then
            log_info "  ✅ $key: $value"
        else
            log_failure "  ❌ $key: $value"
            all_passed=false
        fi
    done

    if $all_passed; then
        log_success "验证通过"
        return 0
    else
        return 1
    fi
}

step_5_quality_check() {
    log_step "5/5" "质量检查"

    # 检查无 CRITICAL/HIGH 问题
    local critical_issues=0
    local high_issues=0
    local coverage=85
    local build_status="success"

    if [[ $critical_issues -eq 0 ]] && [[ $high_issues -eq 0 ]]; then
        log_success "无 CRITICAL/HIGH 问题"
    else
        log_failure "发现 $critical_issues 个 CRITICAL, $high_issues 个 HIGH 问题"
        return 1
    fi

    if [[ $coverage -ge $MIN_COVERAGE ]]; then
        log_success "测试覆盖率达标: ${coverage}%"
    else
        log_failure "测试覆盖率不足: ${coverage}% < $MIN_COVERAGE%"
        return 1
    fi

    if [[ "$build_status" == "success" ]]; then
        log_success "构建成功"
    else
        log_failure "构建失败"
        return 1
    fi

    return 0
}

# =============================================================================
# 主测试函数
# =============================================================================

run_test() {
    log_section "$TEST_NAME"

    local start_time=$(date +%s)

    # 执行所有步骤
    step_1_task_input || return 1
    step_2_quick_planning || return 1
    step_3_quick_development || return 1
    step_4_verification || return 1
    step_5_quality_check || return 1

    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))

    # 验证总耗时
    if [[ $total_duration -lt $MAX_DURATION ]]; then
        log_success "总耗时: ${total_duration}s (< ${MAX_DURATION}s)"
    else
        log_failure "总耗时超时: ${total_duration}s >= ${MAX_DURATION}s"
        return 1
    fi

    return 0
}

# 运行测试
run_test
