#!/bin/bash

# 检查变更是否影响稳定区域

set -e

CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
if [ -z "$CHANGED_FILES" ]; then
  CHANGED_FILES=$(git diff --name-only --cached 2>/dev/null || echo "")
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "✅ 没有文件变更"
  exit 0
fi

STABLE_ZONES=$(grep -A 10 "🔒 稳定模块清单" MEMORY.md 2>/dev/null | grep "src/" | sed 's/.*`\(.*\)`.*/\1/' || echo "")

if [ -z "$STABLE_ZONES" ]; then
  echo "ℹ️  未定义稳定区域"
  exit 0
fi

echo "📋 变更文件："
echo "$CHANGED_FILES"
echo ""
echo "🔒 稳定区域："
echo "$STABLE_ZONES"
echo ""

CONFLICTS=""
for file in $CHANGED_FILES; do
  if echo "$STABLE_ZONES" | grep -q "$file"; then
    CONFLICTS="$CONFLICTS\n- $file"
  fi
done

if [ -n "$CONFLICTS" ]; then
  echo "⚠️  检测到稳定区域变更："
  echo -e "$CONFLICTS"
  echo ""
  echo "❌ 需要用户确认才能继续"
  echo ""
  echo "💡 提示："
  echo "  1. 生成影响报告：./scripts/generate-impact-report.sh"
  echo "  2. 获得用户确认后，更新 MEMORY.md"
  echo "  3. 使用 git commit --no-verify 跳过检查（仅在确认后）"
  exit 1
else
  echo "✅ 未影响稳定区域"
  exit 0
fi
