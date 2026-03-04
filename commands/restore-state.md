# /restore-state - 恢复状态命令

## 功能描述

从检查点恢复项目和任务状态。

## 用法

```bash
/restore-state <检查点 ID> [选项]
```

## 参数

| 参数 | 说明 |
|------|------|
| `检查点 ID` | 检查点 ID 或 "latest" |
| `--verbose` | 显示详细信息 |

## 示例

```bash
# 恢复到最近的检查点
/restore-state latest

# 恢复到指定检查点
/restore-state state-20260304-120000

# 显示详细信息
/restore-state state-20260304-120000 --verbose
```

## 恢复流程

1. **查找检查点文件**
2. **解析检查点数据**
3. **验证 Git 状态**
4. **生成恢复指南**
5. **提供下一步建议**

## 输出示例

```
⚠️ 即将恢复状态

  检查点：state-20260304-120000
  任务：task-52
  阶段：implementation
  分支：task/52

是否继续恢复？(y/N)

ℹ️ 恢复建议:

1. 更新 MEMORY.md 中的任务状态:
   - taskId: task-52
   - currentPhase: implementation

2. 检查修改的文件:
   - src/views/login/index.vue (已修改)
   - src/api/auth.ts (已修改)

3. 查看检查点文件获取更多信息:
   cat checkpoints/state-20260304-120000.json | jq

✅ 恢复指南已生成
```

## 注意事项

1. **未提交更改**：恢复前必须提交或暂存未提交的更改
2. **分支检查**：会自动切换到检查点所在的分支
3. **文件恢复**：仅恢复 Git 跟踪的文件，未跟踪文件需要手动处理

## 相关命令

- `/save-state` - 保存状态
- `/checkpoint list` - 列出检查点
- `/checkpoint restore` - 恢复检查点（Git 级别）
