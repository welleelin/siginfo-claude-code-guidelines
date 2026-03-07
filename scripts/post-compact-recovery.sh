#!/bin/bash

# post-compact-recovery.sh
# Compact 后自动恢复验证脚本

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

# 生成时间戳
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
REPORT_FILE="checkpoints/recovery-${TIMESTAMP}.log"

# 创建检查点目录
mkdir -p checkpoints

# 开始验证
log_info "开始 Compact 后恢复验证..."
echo "═══════════════════════════════════════" | tee "$REPORT_FILE"
echo "  Compact 后恢复验证报告" | tee -a "$REPORT_FILE"
echo "  时间：$(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# 验证步骤计数
TOTAL_CHECKS=6
PASSED_CHECKS=0
FAILED_CHECKS=0

# 1. 检查 MEMORY.md 存在
log_info "1. 检查 MEMORY.md 存在..."
if [ -f "MEMORY.md" ]; then
    log_success "MEMORY.md 存在"
    echo "✅ 1. MEMORY.md 存在" | tee -a "$REPORT_FILE"
    ((PASSED_CHECKS++))
else
    log_error "MEMORY.md 不存在"
    echo "❌ 1. MEMORY.md 不存在" | tee -a "$REPORT_FILE"
    ((FAILED_CHECKS++))
fi

# 2. 验证确定性约束章节完整
log_info "2. 验证确定性约束章节..."
if grep -q "### 确定性约束" MEMORY.md; then
    log_success "确定性约束章节存在"
    echo "✅ 2. 确定性约束章节存在" | tee -a "$REPORT_FILE"
    ((PASSED_CHECKS++))
else
    log_warning "确定性约束章节缺失"
    echo "⚠️  2. 确定性约束章节缺失" | tee -a "$REPORT_FILE"
    ((FAILED_CHECKS++))
fi

# 3. 验证 Mock 接口清单
log_info "3. 验证 Mock 接口清单..."
if grep -q "#### Mock 接口清单" MEMORY.md; then
    MOCK_COUNT=$(grep -c "^| " MEMORY.md | grep -A 10 "Mock 接口清单" | wc -l || echo "0")
    log_success "Mock 接口清单存在"
    echo "✅ 3. Mock 接口清单存在 (${MOCK_COUNT} 个接口)" | tee -a "$REPORT_FILE"
    ((PASSED_CHECKS++))
else
    log_warning "Mock 接口清单缺失"
    echo "⚠️  3. Mock 接口清单缺失" | tee -a "$REPORT_FILE"
    ((FAILED_CHECKS++))
fi

# 4. 验证测试可重复性记录
log_info "4. 验证测试可重复性记录..."
if grep -q "#### 测试可重复性验证" MEMORY.md; then
    log_success "测试可重复性记录存在"
    echo "✅ 4. 测试可重复性记录存在" | tee -a "$REPORT_FILE"
    ((PASSED_CHECKS++))
else
    log_warning "测试可重复性记录缺失"
    echo "⚠️  4. 测试可重复性记录缺失" | tee -a "$REPORT_FILE"
    ((FAILED_CHECKS++))
fi

# 5. 运行确定性验证
log_info "5. 运行确定性验证..."
if [ -f "scripts/verify-determinism.sh" ]; then
    if bash scripts/verify-determinism.sh --quick > /dev/null 2>&1; then
        log_success "确定性验证通过"
        echo "✅ 5. 确定性验证通过" | tee -a "$REPORT_FILE"
        ((PASSED_CHECKS++))
    else
        log_warning "确定性验证发现问题"
        echo "⚠️  5. 确定性验证发现问题" | tee -a "$REPORT_FILE"
        ((FAILED_CHECKS++))
    fi
else
    log_warning "确定性验证脚本不存在"
    echo "⚠️  5. 确定性验证脚本不存在" | tee -a "$REPORT_FILE"
    ((FAILED_CHECKS++))
fi

# 6. 生成恢复报告
log_info "6. 生成恢复报告..."
echo "" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "  验证统计" | tee -a "$REPORT_FILE"
echo "═══════════════════════════════════════" | tee -a "$REPORT_FILE"
echo "总检查项：${TOTAL_CHECKS}" | tee -a "$REPORT_FILE"
echo "通过：${PASSED_CHECKS}" | tee -a "$REPORT_FILE"
echo "失败：${FAILED_CHECKS}" | tee -a "$REPORT_FILE"
echo "通过率：$((PASSED_CHECKS * 100 / TOTAL_CHECKS))%" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# 建议
if [ $FAILED_CHECKS -gt 0 ]; then
    echo "建议：" | tee -a "$REPORT_FILE"

    if ! grep -q "### 确定性约束" MEMORY.md; then
        echo "- 添加确定性约束章节到 MEMORY.md" | tee -a "$REPORT_FILE"
    fi

    if ! grep -q "#### Mock 接口清单" MEMORY.md; then
        echo "- 添加 Mock 接口清单到 MEMORY.md" | tee -a "$REPORT_FILE"
    fi

    if ! grep -q "#### 测试可重复性验证" MEMORY.md; then
        echo "- 添加测试可重复性验证记录到 MEMORY.md" | tee -a "$REPORT_FILE"
    fi

    echo "" | tee -a "$REPORT_FILE"
fi

log_success "恢复验证完成"
log_info "报告已保存到：${REPORT_FILE}"

# 返回状态码
if [ $FAILED_CHECKS -gt 0 ]; then
    exit 1
else
    exit 0
fi
