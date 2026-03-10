# Findings & Decisions
<!--
  WHAT: Your knowledge base for the task. Stores everything you discover and decide.
  WHY: Context windows are limited. This file is your "external memory" - persistent and unlimited.
  WHEN: Update after ANY discovery, especially after 2 view/browser/search operations (2-Action Rule).
-->

## Requirements
<!--
  WHAT: What the user asked for, broken down into specific requirements.
  WHY: Keeps requirements visible so you don't forget what you're building.
  WHEN: Fill this in during Phase 1 (Requirements & Discovery).
-->
- 安装 planning-with-files 技能
- 学习 Manus 风格的三文件规划模式
- 与现有 MEMORY.md 系统融合

## Research Findings
<!--
  WHAT: Key discoveries from web searches, documentation reading, or exploration.
  WHY: Multimodal content (images, browser results) doesn't persist. Write it down immediately.
  WHEN: After EVERY 2 view/browser/search operations, update this section (2-Action Rule).
-->

### Planning-with-Files 核心发现

**版本信息**：
- 版本：v2.18.2
- 基准通过率：96.7%
- 支持平台：16+ IDE

**三文件模式**：
1. `task_plan.md` - 任务路线图（5 阶段工作流）
2. `findings.md` - 知识库（2-Action 规则）
3. `progress.md` - 会话日志（5-Question Reboot Test）

**关键特性**：
- 会话恢复：`/clear` 后自动恢复
- 2-Action 规则：每 2 次搜索后必须更新 findings.md
- 5-Question Reboot Test：验证上下文完整性

**安装位置**：
- `~/.claude/skills/planning-with-files/`

### 融合架构发现

**四层协同机制**：
| 层级 | 文件 | 作用域 | 更新频率 |
|------|------|--------|---------|
| L4 长期记忆 | MEMORY.md | 项目级 | Weekly |
| L3 任务规划 | task_plan.md | 任务级 | 每阶段 |
| L2 知识发现 | findings.md | 任务级 | 每 2 次搜索 |
| L1 会话日志 | progress.md | 会话级 | 实时 |

**最佳实践**：
1. 新任务开始时 → 使用 `/plan` 创建三文件
2. 每 2 次搜索后 → 更新 findings.md
3. 每完成一个阶段 → 更新 task_plan.md + progress.md
4. 任务完成后 → 归档三文件，长期决策合并到 MEMORY.md
5. 长期决策 → 合并到 MEMORY.md

### 文档编写最佳实践

**用户反馈**：用最简单的话描述功能

**改进方式**：
| 原来（技术术语） | 改进后（人话） |
|----------------|---------------|
| AI 编码代理视觉反馈 | 在网页上标注问题，AI 能看到 |
| Manus 风格持久化 Markdown 规划 | 把任务计划写成文件，不怕忘记 |
| IM 桥接工具 | 让你在手机上用微信跟 Claude 聊天 |
| 三文件模式 | 任务计划、发现、进度分开记 |

## Technical Decisions
<!--
  WHAT: Architecture and implementation choices you've made, with reasoning.
  WHY: You'll forget why you chose a technology or approach. This table preserves that knowledge.
  WHEN: Update whenever you make a significant technical choice.
-->
| Decision | Rationale |
|----------|-----------|
| 保留 MEMORY.md 作为长期记忆 | 项目级决策需要持久化保存，跨任务复用 |
| 使用 task_plan.md 作为任务级规划 | 单任务路线图，任务完成后可归档 |
| findings.md 记录任务级发现 | 2-Action 规则确保关键信息不丢失 |
| progress.md 追踪会话进度 | 5-Question Reboot Test 验证上下文 |

## Issues Encountered
<!--
  WHAT: Problems you ran into and how you solved them.
  WHY: Similar to errors in task_plan.md, but focused on broader issues (not just code errors).
  WHEN: Document when you encounter blockers or unexpected challenges.
-->
| Issue | Resolution |
|-------|------------|
| 两个 `/plan` 命令冲突 | 内置 `/plan` 调用 planner agent，planning-with-files 的 `/plan` 创建三文件模式 |

## Resources
<!--
  WHAT: URLs, file paths, API references, documentation links you've found useful.
  WHY: Easy reference for later. Don't lose important links in context.
-->
- GitHub: https://github.com/OthmanAdi/planning-with-files
- 本地安装：`~/.claude/skills/planning-with-files/`
- 融合文档：`guidelines/11-LONG_TERM_MEMORY.md`

## Visual/Browser Findings
<!--
  WHAT: Information you learned from viewing images, PDFs, or browser results.
  WHY: CRITICAL - Visual/multimodal content doesn't persist in context. Must be captured as text.
  WHEN: IMMEDIATELY after viewing images or browser results. Don't wait!
-->
- 暂无

---
<!--
  REMINDER: The 2-Action Rule
  After every 2 view/browser/search operations, you MUST update this file.
  This prevents visual information from being lost when context resets.
-->
*Update this file after every 2 view/browser/search operations*
