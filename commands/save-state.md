# /save-state - 保存状态命令

## 功能描述

保存当前项目和任务状态到检查点文件。

## 用法

```bash
/save-state [原因]
```

## 参数

| 参数 | 说明 |
|------|------|
| `原因` | 保存原因（可选），默认 "manual" |

## 示例

```bash
# 手动保存
/save-state

# 指定保存原因
/save-state 完成需求分析

# 常见保存点
/save-state 开始实现功能
/save-state 测试通过
/save-state 准备提交
```

## 保存的内容

1. **任务信息**
   - 任务 ID
   - 当前阶段
   - 当前步骤

2. **Git 状态**
   - 当前分支
   - Commit hash
   - 更改统计

3. **文件状态**
   - 已修改文件列表
   - 未跟踪文件列表

4. **记忆文件**
   - MEMORY.md 状态
   - 当节日志状态

## 输出示例

```
✅ 状态已保存到 checkpoints/state-20260304-120000.json

状态摘要:
  任务：task-52
  阶段：implementation
  步骤：编写登录页面组件
  Git: +125 -34
```

## 检查点文件位置

```
checkpoints/
├── state-20260304-120000.json
├── state-20260304-150000.json
└── ...
```

## 相关命令

- `/restore-state` - 恢复状态
- `/checkpoint list` - 列出检查点
- `/memory-search` - 搜索记忆
