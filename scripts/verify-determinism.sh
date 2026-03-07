#!/bin/bash

# verify-determinism.sh
# 验证确定性脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 参数解析
QUICK_MODE=false
TEST_NAME=""
TEST_RUNS=3
SCAN_DIR="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --dir)
            SCAN_DIR="$2"
            shift 2
            ;;
        *)
            if [ -z "$TEST_NAME" ]; then
                TEST_NAME="$1"
                shift
            elif [ -z "$TEST_RUNS" ]; then
                TEST_RUNS="$1"
                shift
            else
                shift
            fi
            ;;
    esac
done

log_info "确定性验证"
echo "═══════════════════════════════════════"
echo "  确定性验证报告"
echo "  扫描目录：${SCAN_DIR}"
echo "  模式：$([ "$QUICK_MODE" = true ] && echo "快速检查" || echo "完整验证")"
echo "═══════════════════════════════════════"
echo ""

# 统计变量
ISOLATED_COUNT=0
NOT_ISOLATED_COUNT=0

# 1. 时间依赖检测
log_info "时间依赖检测："
echo ""

# 检测 Date.now()
while IFS=: read -r file line content; do
    if echo "$content" | grep -q "Date\.now()"; then
        log_warning "${file}:${line} - Date.now()"
        ((NOT_ISOLATED_COUNT++))
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec grep -n "Date\.now()" {} + 2>/dev/null || true)

# 检测 new Date()
while IFS=: read -r file line content; do
    if echo "$content" | grep -q "new Date()"; then
        # 检查是否有 jest.useFakeTimers()
        if grep -q "jest\.useFakeTimers()" "$file"; then
            log_success "${file}:${line} - new Date() (已隔离: jest.useFakeTimers())"
            ((ISOLATED_COUNT++))
        else
            log_warning "${file}:${line} - new Date()"
            ((NOT_ISOLATED_COUNT++))
        fi
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec grep -n "new Date()" {} + 2>/dev/null || true)

echo ""

# 2. 随机性检测
log_info "随机性检测："
echo ""

# 检测 Math.random()
while IFS=: read -r file line content; do
    if echo "$content" | grep -q "Math\.random()"; then
        # 检查是否有 seedrandom
        if grep -q "seedrandom" "$file"; then
            log_success "${file}:${line} - Math.random() (已隔离: seedrandom)"
            ((ISOLATED_COUNT++))
        else
            log_warning "${file}:${line} - Math.random()"
            ((NOT_ISOLATED_COUNT++))
        fi
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec grep -n "Math\.random()" {} + 2>/dev/null || true)

# 检测 crypto.randomUUID()
while IFS=: read -r file line content; do
    if echo "$content" | grep -q "crypto\.randomUUID()"; then
        log_warning "${file}:${line} - crypto.randomUUID()"
        ((NOT_ISOLATED_COUNT++))
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec grep -n "crypto\.randomUUID()" {} + 2>/dev/null || true)

echo ""

# 3. 网络请求检测
log_info "网络请求检测："
echo ""

# 检测 fetch()
while IFS=: read -r file line content; do
    if echo "$content" | grep -qE "fetch\(|axios\.(get|post|put|delete)"; then
        # 检查是否有 MSW Mock
        if grep -qE "(setupServer|rest\.(get|post|put|delete))" "$file"; then
            log_success "${file}:${line} - fetch/axios (已隔离: MSW Mock)"
            ((ISOLATED_COUNT++))
        else
            log_warning "${file}:${line} - fetch/axios (未 Mock)"
            ((NOT_ISOLATED_COUNT++))
        fi
    fi
done < <(find "$SCAN_DIR" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) -exec grep -nE "fetch\(|axios\.(get|post|put|delete)" {} + 2>/dev/null || true)

echo ""

# 4. 测试可重复性验证（仅在非快速模式下）
if [ "$QUICK_MODE" = false ] && [ -n "$TEST_NAME" ]; then
    log_info "测试可重复性验证："
    echo ""

    # 运行测试 N 次
    TEST_RESULTS=()
    for i in $(seq 1 $TEST_RUNS); do
        log_info "运行测试 ${i}/${TEST_RUNS}..."

        if npm test -- --testNamePattern="$TEST_NAME" --runInBand > "/tmp/test-result-${i}.log" 2>&1; then
            TEST_RESULTS+=("PASS")
        else
            TEST_RESULTS+=("FAIL")
        fi
    done

    # 检查结果一致性
    FIRST_RESULT="${TEST_RESULTS[0]}"
    CONSISTENT=true

    for result in "${TEST_RESULTS[@]}"; do
        if [ "$result" != "$FIRST_RESULT" ]; then
            CONSISTENT=false
            break
        fi
    done

    if [ "$CONSISTENT" = true ]; then
        log_success "${TEST_NAME} - ${TEST_RUNS} 次运行结果一致"
    else
        log_warning "${TEST_NAME} - ${TEST_RUNS} 次运行结果不一致"
        ((NOT_ISOLATED_COUNT++))
    fi

    echo ""
fi

# 统计
echo "═══════════════════════════════════════"
echo "  统计"
echo "═══════════════════════════════════════"
echo "✅ 已隔离：${ISOLATED_COUNT} 处"
echo "⚠️  未隔离：${NOT_ISOLATED_COUNT} 处"

if [ $((ISOLATED_COUNT + NOT_ISOLATED_COUNT)) -gt 0 ]; then
    ISOLATION_RATE=$((ISOLATED_COUNT * 100 / (ISOLATED_COUNT + NOT_ISOLATED_COUNT)))
else
    ISOLATION_RATE=100
fi

echo "隔离率：${ISOLATION_RATE}%"
echo ""

# 建议
if [ $NOT_ISOLATED_COUNT -gt 0 ]; then
    log_warning "建议："
    echo "  1. 隔离时间依赖：使用 jest.useFakeTimers()"
    echo "  2. 隔离随机性：使用 seedrandom('fixed-seed')"
    echo "  3. Mock 网络请求：使用 MSW 或 nock"
    echo "  4. 确定性排序：显式定义排序规则"
    echo ""
    echo "详细文档：guidelines/14-DETERMINISTIC_DEVELOPMENT.md"
    echo ""
fi

# 返回状态码
if [ $NOT_ISOLATED_COUNT -gt 0 ]; then
    exit 1
else
    log_success "所有不确定性来源已隔离"
    exit 0
fi
