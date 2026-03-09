#!/bin/bash
# =============================================================================
# 四项目集成端到端测试主脚本
# =============================================================================
# 版本: 1.0.0
# 创建日期: 2026-03-09
# 用途: 运行所有 E2E 测试并生成报告
# =============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/.unified/reports/e2e-tests"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# 测试结果
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# =============================================================================
# 辅助函数
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    ((SKIPPED_TESTS++))
    ((TOTAL_TESTS++))
}

log_section() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${BLUE}  $1${NC}"
    echo "═══════════════════════════════════════════════════════════════════"
}

# 检查依赖
check_dependencies() {
    log_section "检查依赖"

    # 检查 claude 命令
    if command -v claude &> /dev/null; then
        log_success "Claude CLI 已安装"
    else
        log_failure "Claude CLI 未安装"
        return 1
    fi

    # 检查 git
    if command -v git &> /dev/null; then
        log_success "Git 已安装"
    else
        log_failure "Git 未安装"
        return 1
    fi

    # 检查 jq
    if command -v jq &> /dev/null; then
        log_success "jq 已安装"
    else
        log_skip "jq 未安装（某些测试可能跳过）"
    fi

    return 0
}

# 运行单个测试脚本
run_test_script() {
    local script_name=$1
    local script_path="$SCRIPT_DIR/$script_name"

    if [[ -f "$script_path" ]]; then
        log_info "运行测试: $script_name"
        if bash "$script_path"; then
            log_success "$script_name"
            return 0
        else
            log_failure "$script_name"
            return 1
        fi
    else
        log_skip "$script_name (脚本不存在)"
        return 2
    fi
}

# =============================================================================
# 测试套件
# =============================================================================

# 测试 1: Quick Flow 端到端测试
test_quick_flow() {
    log_section "测试 1: Quick Flow 端到端测试"
    run_test_script "test-quick-flow.sh"
}

# 测试 2: Standard Flow 端到端测试
test_standard_flow() {
    log_section "测试 2: Standard Flow 端到端测试"
    run_test_script "test-standard-flow.sh"
}

# 测试 3: Enterprise Flow 端到端测试
test_enterprise_flow() {
    log_section "测试 3: Enterprise Flow 端到端测试"
    run_test_script "test-enterprise-flow.sh"
}

# 测试 4: Team 模式协作测试
test_team_mode() {
    log_section "测试 4: Team 模式协作测试"
    run_test_script "test-team-mode.sh"
}

# 测试 5: Autopilot 模式测试
test_autopilot_mode() {
    log_section "测试 5: Autopilot 模式测试"
    run_test_script "test-autopilot-mode.sh"
}

# 测试 6: 并行执行优化测试
test_parallel_execution() {
    log_section "测试 6: 并行执行优化测试"
    run_test_script "test-parallel-execution.sh"
}

# 测试 7: 性能优化验证
test_performance() {
    log_section "测试 7: 性能优化验证"
    run_test_script "test-performance.sh"
}

# 测试 8: 成本优化验证
test_cost_optimization() {
    log_section "测试 8: 成本优化验证"
    run_test_script "test-cost-optimization.sh"
}

# =============================================================================
# 报告生成
# =============================================================================

generate_report() {
    log_section "生成测试报告"

    mkdir -p "$REPORT_DIR"

    local report_file="$REPORT_DIR/e2e-test-report-$TIMESTAMP.md"

    cat > "$report_file" << EOF
# 四项目集成端到端测试报告

> **测试时间**: $(date)
> **测试环境**: $(uname -a)

---

## 📊 测试摘要

| 指标 | 数量 |
|------|------|
| **总测试数** | $TOTAL_TESTS |
| **通过** | $PASSED_TESTS |
| **失败** | $FAILED_TESTS |
| **跳过** | $SKIPPED_TESTS |
| **通过率** | $(awk "BEGIN {printf \"%.1f%%\", ($PASSED_TESTS/($TOTAL_TESTS>0?$TOTAL_TESTS:1))*100}") |

---

## 📈 测试结果

### 通过的测试
$([ $PASSED_TESTS -gt 0 ] && echo "- ✅ 所有通过测试已记录" || echo "- 无")

### 失败的测试
$([ $FAILED_TESTS -gt 0 ] && echo "- ❌ 需要检查失败的测试" || echo "- 无")

### 跳过的测试
$([ $SKIPPED_TESTS -gt 0 ] && echo "- ⚠️ 某些测试被跳过" || echo "- 无")

---

## 🔍 详细日志

详细测试日志请查看: \`$REPORT_DIR/logs/\`

---

*报告生成时间: $(date)*
EOF

    log_info "测试报告已生成: $report_file"

    # 同时生成 JSON 格式
    local json_file="$REPORT_DIR/e2e-test-result-$TIMESTAMP.json"
    cat > "$json_file" << EOF
{
  "timestamp": "$TIMESTAMP",
  "summary": {
    "total": $TOTAL_TESTS,
    "passed": $PASSED_TESTS,
    "failed": $FAILED_TESTS,
    "skipped": $SKIPPED_TESTS,
    "passRate": $(awk "BEGIN {printf \"%.2f\", ($PASSED_TESTS/($TOTAL_TESTS>0?$TOTAL_TESTS:1))}")
  },
  "environment": {
    "os": "$(uname -s)",
    "kernel": "$(uname -r)",
    "arch": "$(uname -m)"
  }
}
EOF

    log_info "JSON 结果已生成: $json_file"
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║         四项目集成端到端测试                                        ║"
    echo "║         Four Projects Integration E2E Testing                      ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""

    # 检查依赖
    if ! check_dependencies; then
        echo ""
        echo -e "${RED}错误: 依赖检查失败，请安装缺失的依赖${NC}"
        exit 1
    fi

    # 创建日志目录
    mkdir -p "$REPORT_DIR/logs"

    # 运行测试
    test_quick_flow
    test_standard_flow
    test_enterprise_flow
    test_team_mode
    test_autopilot_mode
    test_parallel_execution
    test_performance
    test_cost_optimization

    # 生成报告
    generate_report

    # 打印摘要
    echo ""
    log_section "测试完成摘要"
    echo ""
    echo "  总测试数: $TOTAL_TESTS"
    echo -e "  ${GREEN}通过: $PASSED_TESTS${NC}"
    echo -e "  ${RED}失败: $FAILED_TESTS${NC}"
    echo -e "  ${YELLOW}跳过: $SKIPPED_TESTS${NC}"
    echo ""

    # 返回码
    if [ $FAILED_TESTS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# 运行主函数
main "$@"
