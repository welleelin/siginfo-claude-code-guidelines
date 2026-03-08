#!/bin/bash

# 生成变更影响报告

set -e

REPORT_FILE="impact-report-$(date +%Y%m%d-%H%M%S).md"

cat > "$REPORT_FILE" <<EOF
# 变更影响报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
**任务 ID**: ${TASK_ID:-未指定}

## 变更文件

EOF

git diff --name-status HEAD >> "$REPORT_FILE" 2>/dev/null || git diff --name-status --cached >> "$REPORT_FILE" 2>/dev/null || echo "无变更" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" <<EOF

## 稳定模块影响

EOF

STABLE_ZONES=$(grep -A 10 "🔒 稳定模块清单" MEMORY.md 2>/dev/null | grep "src/" | sed 's/.*`\(.*\)`.*/\1/' || echo "")
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only --cached 2>/dev/null || echo "")

CONFLICTS=""
for file in $CHANGED_FILES; do
  if echo "$STABLE_ZONES" | grep -q "$file"; then
    CONFLICTS="$CONFLICTS\n- 🟠 $file"
  fi
done

if [ -n "$CONFLICTS" ]; then
  echo -e "$CONFLICTS" >> "$REPORT_FILE"
else
  echo "✅ 无稳定模块影响" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" <<EOF

## 风险评估

- [ ] 影响级别：🟢 无影响 / 🟡 间接影响 / 🟠 直接影响 / 🔴 破坏性影响
- [ ] 需要重新测试：是 / 否
- [ ] 需要用户确认：是 / 否

## 建议方案

（请填写实现方案）

## 需要用户确认

- [ ] 是否允许修改稳定模块？
- [ ] 选择哪个实现方案？
- [ ] 是否需要重新进行完整测试？

EOF

echo "✅ 影响报告已生成：$REPORT_FILE"
echo ""
echo "📋 下一步："
echo "  1. 填写报告中的风险评估和建议方案"
echo "  2. 发送报告给用户确认"
echo "  3. 获得确认后继续开发"
