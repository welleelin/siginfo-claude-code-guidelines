#!/bin/bash

# check-api-completeness.sh
# API 完整性检查脚本

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
API_LIST_FILE="${1:-api-checklist.md}"
API_BASE_URL="${2:-http://localhost:8000}"

log_info "API 完整性检查"
echo "═══════════════════════════════════════"
echo "  API 完整性检查报告"
echo "  检查时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "  API 清单：${API_LIST_FILE}"
echo "  API 基础 URL：${API_BASE_URL}"
echo "═══════════════════════════════════════"
echo ""

# 检查 API 清单文件是否存在
if [ ! -f "$API_LIST_FILE" ]; then
    log_error "API 清单文件不存在：${API_LIST_FILE}"
    echo ""
    echo "请创建 API 清单文件，格式如下："
    echo ""
    cat <<'EOF'
## API 清单

- [ ] POST /api/auth/login - 用户登录
- [ ] GET /api/auth/verify - 验证 Token
- [ ] GET /api/user/profile - 获取用户信息
EOF
    echo ""
    exit 1
fi

# 统计变量
TOTAL_APIS=0
COMPLETED_APIS=0
INCOMPLETE_APIS=0
FAILED_APIS=0

# 临时文件
REPORT_FILE="/tmp/api-completeness-report-$(date +%s).md"

# 生成报告头部
cat > "$REPORT_FILE" <<EOF
# API 完整性检查报告

**检查时间**：$(date '+%Y-%m-%d %H:%M:%S')
**API 基础 URL**：${API_BASE_URL}

## 检查结果

EOF

log_info "开始检查 API..."
echo ""

# 解析 API 清单并检查
while IFS= read -r line; do
    # 跳过空行和标题行
    if [[ -z "$line" ]] || [[ "$line" =~ ^#.* ]]; then
        continue
    fi

    # 解析 API 行：- [ ] METHOD /path - Description
    if [[ "$line" =~ ^-[[:space:]]\[([[:space:]]|x)\][[:space:]]([A-Z]+)[[:space:]]([^[:space:]]+)[[:space:]]-[[:space:]](.+)$ ]]; then
        CHECKED="${BASH_REMATCH[1]}"
        METHOD="${BASH_REMATCH[2]}"
        PATH="${BASH_REMATCH[3]}"
        DESCRIPTION="${BASH_REMATCH[4]}"

        ((TOTAL_APIS++))

        # 检查 API 是否已标记为完成
        if [[ "$CHECKED" == "x" ]]; then
            log_success "${METHOD} ${PATH} - ${DESCRIPTION} (已标记完成)"
            ((COMPLETED_APIS++))
            echo "| ${METHOD} ${PATH} | ${DESCRIPTION} | ✅ 完成 | - |" >> "$REPORT_FILE"
            continue
        fi

        # 尝试调用 API 检查是否可用
        log_info "检查 ${METHOD} ${PATH}..."

        API_URL="${API_BASE_URL}${PATH}"

        # 根据 HTTP 方法构造请求
        case "$METHOD" in
            GET)
                RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_URL" 2>/dev/null || echo "000")
                ;;
            POST)
                RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
                    -H "Content-Type: application/json" \
                    -d '{}' 2>/dev/null || echo "000")
                ;;
            PUT)
                RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$API_URL" \
                    -H "Content-Type: application/json" \
                    -d '{}' 2>/dev/null || echo "000")
                ;;
            DELETE)
                RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API_URL" 2>/dev/null || echo "000")
                ;;
            *)
                RESPONSE="000"
                ;;
        esac

        # 判断 API 状态
        if [[ "$RESPONSE" == "000" ]]; then
            log_error "${METHOD} ${PATH} - 无法连接"
            ((FAILED_APIS++))
            echo "| ${METHOD} ${PATH} | ${DESCRIPTION} | ❌ 无法连接 | 检查服务是否启动 |" >> "$REPORT_FILE"
        elif [[ "$RESPONSE" == "404" ]]; then
            log_warning "${METHOD} ${PATH} - 未实现 (404)"
            ((INCOMPLETE_APIS++))
            echo "| ${METHOD} ${PATH} | ${DESCRIPTION} | ⚠️ 未实现 | 需要开发 |" >> "$REPORT_FILE"
        elif [[ "$RESPONSE" =~ ^(200|201|204|400|401|403)$ ]]; then
            log_success "${METHOD} ${PATH} - 已实现 (${RESPONSE})"
            ((COMPLETED_APIS++))
            echo "| ${METHOD} ${PATH} | ${DESCRIPTION} | ✅ 已实现 | HTTP ${RESPONSE} |" >> "$REPORT_FILE"
        else
            log_warning "${METHOD} ${PATH} - 响应异常 (${RESPONSE})"
            ((INCOMPLETE_APIS++))
            echo "| ${METHOD} ${PATH} | ${DESCRIPTION} | ⚠️ 响应异常 | HTTP ${RESPONSE} |" >> "$REPORT_FILE"
        fi
    fi
done < "$API_LIST_FILE"

echo ""
echo "═══════════════════════════════════════"
echo "  统计"
echo "═══════════════════════════════════════"
echo "总 API 数：${TOTAL_APIS}"
echo "已完成：${COMPLETED_APIS}"
echo "未完成：${INCOMPLETE_APIS}"
echo "无法连接：${FAILED_APIS}"

if [ $TOTAL_APIS -gt 0 ]; then
    COMPLETION_RATE=$((COMPLETED_APIS * 100 / TOTAL_APIS))
else
    COMPLETION_RATE=0
fi

echo "完成率：${COMPLETION_RATE}%"
echo ""

# 添加统计到报告
cat >> "$REPORT_FILE" <<EOF

## 统计

| 指标 | 数量 |
|------|------|
| 总 API 数 | ${TOTAL_APIS} |
| 已完成 | ${COMPLETED_APIS} |
| 未完成 | ${INCOMPLETE_APIS} |
| 无法连接 | ${FAILED_APIS} |
| 完成率 | ${COMPLETION_RATE}% |

EOF

# 决策建议
if [ $COMPLETION_RATE -eq 100 ]; then
    log_success "所有 API 已完成，可以继续进行测试"
    cat >> "$REPORT_FILE" <<EOF
## 决策

✅ **可以继续测试**
- 所有 API 已完成（${COMPLETED_APIS}/${TOTAL_APIS}）
- 可以进行前后端联调测试
- 可以进行 E2E 端到端测试

EOF
elif [ $COMPLETION_RATE -ge 80 ]; then
    log_warning "大部分 API 已完成（${COMPLETION_RATE}%），建议标记 Mock 后继续测试"
    cat >> "$REPORT_FILE" <<EOF
## 决策

⚠️ **建议标记 Mock 后继续测试**
- 核心 API 已完成（${COMPLETED_APIS}/${TOTAL_APIS}）
- 未完成的 API 需要标记为 Mock
- 后续替换为真实 API

### 需要标记的 Mock API

EOF

    # 列出未完成的 API
    while IFS= read -r line; do
        if [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\][[:space:]]([A-Z]+)[[:space:]]([^[:space:]]+)[[:space:]]-[[:space:]](.+)$ ]]; then
            METHOD="${BASH_REMATCH[1]}"
            PATH="${BASH_REMATCH[2]}"
            DESCRIPTION="${BASH_REMATCH[3]}"
            cat >> "$REPORT_FILE" <<EOF
\`\`\`typescript
// ⚠️ MOCK: ${DESCRIPTION}，预计 YYYY-MM-DD 替换
await page.route('**${PATH}', route => {
  route.fulfill({ status: 200, body: JSON.stringify({ success: true }) })
})
\`\`\`

EOF
        fi
    done < "$API_LIST_FILE"

else
    log_error "API 完成率过低（${COMPLETION_RATE}%），建议先完成核心 API"
    cat >> "$REPORT_FILE" <<EOF
## 决策

❌ **建议先完成核心 API**
- API 完成率过低（${COMPLETED_APIS}/${TOTAL_APIS}）
- 建议优先开发核心 API
- 完成后再进行测试

### 需要优先开发的 API

EOF

    # 列出未完成的 API
    while IFS= read -r line; do
        if [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\][[:space:]]([A-Z]+)[[:space:]]([^[:space:]]+)[[:space:]]-[[:space:]](.+)$ ]]; then
            METHOD="${BASH_REMATCH[1]}"
            PATH="${BASH_REMATCH[2]}"
            DESCRIPTION="${BASH_REMATCH[3]}"
            echo "- ${METHOD} ${PATH} - ${DESCRIPTION}" >> "$REPORT_FILE"
        fi
    done < "$API_LIST_FILE"
fi

# 保存报告
FINAL_REPORT="api-completeness-report-$(date +%Y%m%d-%H%M%S).md"
cp "$REPORT_FILE" "$FINAL_REPORT"

log_info "报告已保存到：${FINAL_REPORT}"
echo ""

# 显示报告内容
cat "$REPORT_FILE"

# 返回状态码
if [ $COMPLETION_RATE -eq 100 ]; then
    exit 0
elif [ $COMPLETION_RATE -ge 80 ]; then
    exit 1
else
    exit 2
fi
