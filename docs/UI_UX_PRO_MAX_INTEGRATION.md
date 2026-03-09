# UI UX Pro Max Skill 集成指南

> **版本**：1.0.0
> **最后更新**：2026-03-08
> **来源**：https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

---

## 📋 概述

UI UX Pro Max Skill 是一个强大的设计智能系统，为构建专业 UI/UX 提供多平台支持。它包含 100 条推理规则、67 种 UI 风格、96 种配色方案等丰富的设计资源。

### 核心价值

| 特性 | 说明 |
|------|------|
| 🧠 **AI 推理引擎** | 100 条行业推理规则，智能设计决策 |
| 🎨 **67 种 UI 风格** | 玻璃态、黏土态、极简主义、野兽派等 |
| 🌈 **96 种配色方案** | 专业配色系统，覆盖各种场景 |
| 📝 **57 种字体配对** | 经过验证的字体组合 |
| 📊 **25 种图表类型** | 数据可视化组件 |
| 💻 **13 种技术栈** | React、Vue、Angular、SwiftUI 等 |
| 📐 **99 条 UX 指南** | 用户体验最佳实践 |

---

## 🏗️ 架构设计

### 与 sig-guidelines 集成架构

```
┌─────────────────────────────────────────────────────────────┐
│          UI UX Pro Max + sig-guidelines 集成                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 2: 任务规划 - UI/UX 设计                             │
│  ├─ 需求分析                                                │
│  ├─ 风格选择 ◄───── UI UX Pro Max (67 种风格)               │
│  ├─ 配色方案 ◄───── UI UX Pro Max (96 种配色)               │
│  ├─ 字体配对 ◄───── UI UX Pro Max (57 种配对)               │
│  └─ 设计创建 ◄───── Pencil MCP (AI 生成设计)                │
│                                                             │
│  Phase 4: TDD 开发                                          │
│  ├─ 组件开发 ◄───── UI UX Pro Max (组件库)                  │
│  ├─ 图表集成 ◄───── UI UX Pro Max (25 种图表)               │
│  └─ UX 验证 ◄────── UI UX Pro Max (99 条指南)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 与 Pencil 的协作流程

```
1. UI UX Pro Max 提供设计决策
   ├─ 选择 UI 风格（如 Glassmorphism）
   ├─ 选择配色方案（如 Ocean Blue）
   └─ 选择字体配对（如 Inter + Fira Code）

2. Pencil 执行设计创建
   ├─ 根据风格生成设计稿
   ├─ 应用配色方案
   └─ 应用字体配对

3. 代码生成与验证
   ├─ Pencil 导出代码
   ├─ UI UX Pro Max 验证 UX 指南
   └─ 输出最终实现
```

---

## 🎨 67 种 UI 风格速查表

### 现代风格

| 风格 | 特点 | 适用场景 |
|------|------|---------|
| **Glassmorphism** | 玻璃态、半透明、模糊背景 | 现代 Web 应用、仪表板 |
| **Neumorphism** | 软阴影、浮雕效果 | 移动应用、简洁界面 |
| **Claymorphism** | 黏土质感、柔和阴影 | 创意应用、儿童产品 |
| **Minimalism** | 极简、留白、清晰层次 | 企业官网、SaaS 产品 |
| **Brutalism** | 野兽派、粗犷、对比强烈 | 艺术网站、创意作品集 |

### 经典风格

| 风格 | 特点 | 适用场景 |
|------|------|---------|
| **Flat Design** | 扁平化、纯色、无阴影 | 移动应用、简洁界面 |
| **Material Design** | Google 设计语言、卡片式 | Android 应用、Web 应用 |
| **Skeuomorphism** | 拟物化、真实质感 | iOS 早期风格、特定场景 |
| **Swiss Design** | 瑞士风格、网格系统 | 企业品牌、专业网站 |

### 行业风格

| 风格 | 特点 | 适用场景 |
|------|------|---------|
| **Corporate** | 企业风格、专业、稳重 | B2B 产品、企业官网 |
| **E-commerce** | 电商风格、产品展示 | 在线商城、零售平台 |
| **SaaS** | SaaS 风格、功能导向 | 企业软件、工具平台 |
| **Gaming** | 游戏风格、动感、炫酷 | 游戏应用、娱乐平台 |
| **Healthcare** | 医疗风格、清洁、可信 | 医疗应用、健康平台 |

**完整列表**：查看 [UI_STYLES.md](./UI_STYLES.md)（67 种风格详细说明）

---

## 🌈 96 种配色方案速查表

### 专业配色

| 配色方案 | 主色 | 辅色 | 适用场景 |
|---------|------|------|---------|
| **Ocean Blue** | #0066CC | #00A3E0 | 企业应用、金融科技 |
| **Forest Green** | #10B981 | #059669 | 环保、健康、自然 |
| **Sunset Orange** | #F59E0B | #EF4444 | 创意、活力、电商 |
| **Royal Purple** | #8B5CF6 | #6366F1 | 奢侈品、艺术、创意 |
| **Midnight Dark** | #1F2937 | #374151 | 暗色模式、专业工具 |

### 行业配色

| 行业 | 推荐配色 | 说明 |
|------|---------|------|
| **金融科技** | Ocean Blue, Trust Navy | 专业、可信、稳重 |
| **医疗健康** | Medical Blue, Health Green | 清洁、安全、可靠 |
| **电商零售** | Vibrant Red, Warm Orange | 活力、促销、吸引 |
| **教育培训** | Knowledge Blue, Growth Green | 知识、成长、希望 |
| **娱乐游戏** | Neon Purple, Electric Blue | 炫酷、动感、刺激 |

**完整列表**：查看 [COLOR_PALETTES.md](./COLOR_PALETTES.md)（96 种配色详细说明）

---

## 📝 57 种字体配对速查表

### 经典配对

| 配对名称 | 标题字体 | 正文字体 | 适用场景 |
|---------|---------|---------|---------|
| **Modern Sans** | Inter | Inter | 现代 Web 应用 |
| **Tech Stack** | SF Pro | SF Mono | 技术文档、代码 |
| **Editorial** | Playfair Display | Source Sans Pro | 博客、新闻 |
| **Corporate** | Helvetica Neue | Arial | 企业官网、B2B |
| **Creative** | Montserrat | Open Sans | 创意作品集 |

### 代码字体

| 配对名称 | 标题字体 | 代码字体 | 适用场景 |
|---------|---------|---------|---------|
| **Developer** | Inter | Fira Code | 开发工具、IDE |
| **Terminal** | JetBrains Mono | JetBrains Mono | 终端、命令行 |
| **Code Editor** | Source Code Pro | Source Code Pro | 代码编辑器 |

**完整列表**：查看 [FONT_PAIRINGS.md](./FONT_PAIRINGS.md)（57 种配对详细说明）

---

## 📊 25 种图表类型速查表

### 基础图表

| 图表类型 | 用途 | 示例场景 |
|---------|------|---------|
| **Line Chart** | 趋势展示 | 销售趋势、用户增长 |
| **Bar Chart** | 对比展示 | 产品对比、区域对比 |
| **Pie Chart** | 占比展示 | 市场份额、分类占比 |
| **Area Chart** | 累积趋势 | 累计销售、堆叠数据 |
| **Scatter Plot** | 分布关系 | 相关性分析、聚类 |

### 高级图表

| 图表类型 | 用途 | 示例场景 |
|---------|------|---------|
| **Heatmap** | 密度展示 | 用户行为热图、时间分布 |
| **Treemap** | 层级占比 | 文件大小、预算分配 |
| **Sankey Diagram** | 流向展示 | 用户流程、能量流动 |
| **Radar Chart** | 多维对比 | 能力雷达图、产品对比 |
| **Funnel Chart** | 转化漏斗 | 销售漏斗、用户转化 |

**完整列表**：查看 [CHART_TYPES.md](./CHART_TYPES.md)（25 种图表详细说明）

---

## 📐 99 条 UX 指南速查表

### 核心原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **一致性** | 保持界面元素的一致性 | 按钮样式、颜色、间距统一 |
| **反馈** | 及时提供操作反馈 | 加载状态、成功提示、错误提示 |
| **容错性** | 允许用户犯错并提供恢复 | 撤销操作、确认对话框 |
| **可访问性** | 确保所有用户都能使用 | 键盘导航、屏幕阅读器支持 |
| **效率** | 减少用户操作步骤 | 快捷键、批量操作、智能默认值 |

### 交互设计

| 指南 | 说明 | 最佳实践 |
|------|------|---------|
| **按钮设计** | 主次分明、状态清晰 | 主按钮突出、次按钮弱化 |
| **表单设计** | 简洁、分组、验证 | 实时验证、清晰错误提示 |
| **导航设计** | 清晰、一致、可预测 | 面包屑、高亮当前位置 |
| **搜索设计** | 快速、准确、建议 | 自动完成、搜索历史 |
| **加载设计** | 进度、占位、优雅降级 | 骨架屏、进度条、加载动画 |

### 视觉设计

| 指南 | 说明 | 最佳实践 |
|------|------|---------|
| **颜色使用** | 对比、层次、情感 | 主色 60%、辅色 30%、强调色 10% |
| **排版设计** | 可读性、层次、节奏 | 标题 2-3 级、正文 16px+ |
| **间距设计** | 呼吸感、分组、对齐 | 8px 基准、倍数递增 |
| **图标设计** | 识别性、一致性、大小 | 24x24px 标准、统一风格 |

**完整列表**：查看 [UX_GUIDELINES.md](./UX_GUIDELINES.md)（99 条指南详细说明）

---

## 🛠️ 使用场景

### 场景 1：新项目设计决策

```markdown
## 任务：设计一个 SaaS 产品的仪表板

### Step 1: 选择 UI 风格
参考 UI UX Pro Max - 67 种风格
推荐：Glassmorphism（现代、专业）

### Step 2: 选择配色方案
参考 UI UX Pro Max - 96 种配色
推荐：Ocean Blue（企业应用）

### Step 3: 选择字体配对
参考 UI UX Pro Max - 57 种配对
推荐：Modern Sans（Inter + Inter）

### Step 4: 使用 Pencil 创建设计
在 Claude Code 中：
```
使用 Pencil 创建 SaaS 仪表板设计：
- 风格：Glassmorphism
- 配色：Ocean Blue (#0066CC, #00A3E0)
- 字体：Inter
- 包含：侧边栏导航、数据卡片、图表区域
```
```

### 场景 2：设计系统构建

```markdown
## 任务：为公司构建设计系统

### Step 1: 定义设计原则
参考 UI UX Pro Max - 99 条 UX 指南
选择核心原则：一致性、反馈、容错性、可访问性

### Step 2: 建立配色系统
参考 UI UX Pro Max - 96 种配色
选择主配色：Ocean Blue
定义语义色：成功、警告、错误、信息

### Step 3: 建立排版系统
参考 UI UX Pro Max - 57 种字体配对
选择：Modern Sans（Inter）
定义层级：H1-H6、正文、小字

### Step 4: 建立组件库
使用 Pencil 创建组件：
- 按钮（主要、次要、文本）
- 表单（输入框、选择器、复选框）
- 导航（顶部导航、侧边栏、面包屑）
- 反馈（提示、对话框、加载）
```

### 场景 3：图表可视化

```markdown
## 任务：为数据分析平台设计图表

### Step 1: 选择图表类型
参考 UI UX Pro Max - 25 种图表
需求分析：
- 趋势展示 → Line Chart
- 对比展示 → Bar Chart
- 占比展示 → Pie Chart
- 分布关系 → Scatter Plot

### Step 2: 设计图表样式
配色：使用 Ocean Blue 配色方案
字体：使用 Inter 字体
间距：使用 8px 基准

### Step 3: 使用 Pencil 创建
在 Claude Code 中：
```
使用 Pencil 创建数据图表组件：
- Line Chart：销售趋势图
- Bar Chart：产品对比图
- Pie Chart：市场份额图
- 配色：Ocean Blue
- 字体：Inter
```
```

### 场景 4：UX 审查

```markdown
## 任务：审查现有产品的 UX 问题

### Step 1: 使用 99 条 UX 指南
逐条检查：
- [ ] 一致性：按钮样式是否统一？
- [ ] 反馈：操作是否有及时反馈？
- [ ] 容错性：是否允许撤销操作？
- [ ] 可访问性：是否支持键盘导航？
- [ ] 效率：是否有快捷操作？

### Step 2: 生成问题清单
发现的问题：
1. 按钮样式不统一（3 种不同样式）
2. 表单提交无加载状态
3. 删除操作无确认对话框
4. 无键盘导航支持
5. 搜索无自动完成

### Step 3: 提出改进方案
参考 UI UX Pro Max 最佳实践：
1. 统一按钮样式（参考按钮设计指南）
2. 添加加载状态（参考加载设计指南）
3. 添加确认对话框（参考容错性原则）
4. 实现键盘导航（参考可访问性指南）
5. 添加搜索建议（参考搜索设计指南）
```

---

## 📝 与记忆系统集成

### 记忆文件布局

```
project/
├── MEMORY.md                          # 长期记忆
│   ├── 🎨 UI UX Pro Max 使用记录
│   ├── 📐 设计决策历史
│   └── 🖼️ 风格配色选择
├── memory/
│   ├── 2026-03-08.md                  # 每日日志
│   │   ├── 🕐 [Hourly] 设计决策记录
│   │   ├── 💡 风格选择原因
│   │   └── 🔗 相关资源链接
│   └── archive/
└── design-system/                     # 设计系统
    ├── ui-styles.md                   # 选择的 UI 风格
    ├── color-palette.md               # 选择的配色方案
    ├── font-pairing.md                # 选择的字体配对
    └── ux-guidelines.md               # 应用的 UX 指南
```

### 设计决策记录模板

```markdown
## 💡 设计决策 (MEMORY.md)

### 2026-03-08 - SaaS 仪表板设计

**UI 风格**: Glassmorphism
**选择原因**: 现代、专业、适合企业应用

**配色方案**: Ocean Blue
**主色**: #0066CC
**辅色**: #00A3E0
**选择原因**: 企业应用、可信、专业

**字体配对**: Modern Sans
**标题**: Inter Bold
**正文**: Inter Regular
**代码**: Fira Code
**选择原因**: 现代、可读性好、支持中文

**应用的 UX 指南**:
1. 一致性 - 统一按钮样式和间距
2. 反馈 - 所有操作都有加载状态
3. 容错性 - 删除操作有确认对话框
4. 可访问性 - 支持键盘导航
5. 效率 - 提供快捷键和批量操作

**相关文件**:
- designs/dashboard.fig
- src/components/Dashboard.tsx
- src/styles/design-tokens.css
```

---

## 🔗 与其他工具集成

### 与 Pencil 集成

```markdown
## 工作流：UI UX Pro Max → Pencil → 代码

1. **设计决策阶段**（UI UX Pro Max）
   - 选择 UI 风格
   - 选择配色方案
   - 选择字体配对
   - 确定 UX 指南

2. **设计创建阶段**（Pencil）
   - 根据决策创建设计稿
   - 应用风格和配色
   - 应用字体和间距

3. **代码生成阶段**（Pencil CLI）
   - 导出为 React/Vue 组件
   - 应用 Tailwind CSS
   - 生成设计 Token

4. **UX 验证阶段**（UI UX Pro Max）
   - 对照 99 条 UX 指南
   - 检查可访问性
   - 验证交互反馈
```

### 与 BMAD Method 集成

```markdown
## BMAD Method UX 设计流程 + UI UX Pro Max

### Phase 2: 任务规划 - UI/UX 设计

#### Step 1: 需求分析
使用 BMAD Method Analyst Agent

#### Step 2: 风格决策
使用 UI UX Pro Max：
- 选择 UI 风格（67 种）
- 选择配色方案（96 种）
- 选择字体配对（57 种）

#### Step 3: 设计创建
使用 BMAD Method UX Designer Agent + Pencil

#### Step 4: UX 验证
使用 UI UX Pro Max：
- 对照 99 条 UX 指南
- 生成 UX 审查报告
```

---

## 📚 快速参考

### 设计决策流程图

```
需求分析
    │
    ▼
选择 UI 风格 ◄─── UI UX Pro Max (67 种)
    │
    ▼
选择配色方案 ◄─── UI UX Pro Max (96 种)
    │
    ▼
选择字体配对 ◄─── UI UX Pro Max (57 种)
    │
    ▼
创建设计稿 ◄───── Pencil MCP
    │
    ▼
UX 验证 ◄──────── UI UX Pro Max (99 条指南)
    │
    ▼
代码生成 ◄──────── Pencil CLI
    │
    ▼
最终实现
```

### 常用命令

```bash
# 查看 UI 风格列表
cat docs/UI_STYLES.md

# 查看配色方案列表
cat docs/COLOR_PALETTES.md

# 查看字体配对列表
cat docs/FONT_PAIRINGS.md

# 查看 UX 指南列表
cat docs/UX_GUIDELINES.md

# 查看图表类型列表
cat docs/CHART_TYPES.md
```

---

## 🎓 最佳实践

### 1. 设计决策记录

每次设计决策都应记录到 MEMORY.md：
- 选择的风格、配色、字体
- 选择原因和考虑因素
- 应用的 UX 指南
- 相关设计文件

### 2. 设计系统一致性

使用 UI UX Pro Max 确保设计系统一致性：
- 统一的 UI 风格
- 统一的配色方案
- 统一的字体配对
- 统一的 UX 指南

### 3. UX 审查流程

定期使用 99 条 UX 指南审查产品：
- 每个 Sprint 结束后审查
- 新功能上线前审查
- 用户反馈后审查

### 4. 持续学习

定期更新 UI UX Pro Max 资源：
- 关注新的 UI 风格趋势
- 学习新的配色方案
- 了解新的 UX 最佳实践

---

## 📊 效能指标

| 指标 | 传统方式 | 使用 UI UX Pro Max | 提升 |
|------|---------|-------------------|------|
| 设计决策时间 | 2-3 小时 | 10-15 分钟 | 12x |
| 配色方案选择 | 1 小时 | 5 分钟 | 12x |
| 字体配对选择 | 30 分钟 | 3 分钟 | 10x |
| UX 审查时间 | 4 小时 | 30 分钟 | 8x |
| 设计系统构建 | 2 周 | 2 天 | 7x |

---

## 🔗 相关文档

- [UI UX Pro Max GitHub](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- [Pencil 集成指南](./PENCIL_INTEGRATION.md)
- [BMAD Method 集成指南](./BMAD_METHOD_INTEGRATION.md)
- [行动准则](../guidelines/01-ACTION_GUIDELINES.md)

---

*版本：1.0.0*
*最后更新：2026-03-08*

> **核心理念**：
> 1. 设计智能 - 使用 AI 推理引擎辅助设计决策
> 2. 资源丰富 - 67 种风格、96 种配色、57 种字体、99 条指南
> 3. 系统化 - 建立完整的设计系统和 UX 规范
> 4. 可复用 - 设计决策可记录、可复用、可传承
