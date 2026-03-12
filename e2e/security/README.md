# Playwright 安全测试套件

> 基于 OWASP Top 10 的企业级安全渗透测试方案
> 配合 Shannon AI 渗透测试工具使用效果更佳

---

## 📋 概述

本安全测试套件提供了一套完整的 Playwright E2E 安全测试配置和测试用例，覆盖：

- **XSS（跨站脚本攻击）** - 反射型、存储型、DOM 型
- **CSRF（跨站请求伪造）** - Token 验证、Referer 检查
- **SQL/NoSQL 注入** - 认证绕过、联合查询、盲注
- **BOLA（对象级授权破坏）** - 水平越权、垂直越权
- **认证安全** - Token 劫持、会话固定、暴力破解

---

## 🚀 快速开始

### 前置要求

- Node.js 18+
- npm 或 yarn
- 被测应用运行中

### 安装步骤

```bash
# Step 1: 初始化 Playwright（如果尚未安装）
npx playwright init

# Step 2: 安装浏览器
npx playwright install

# Step 3: 复制配置文件
cp playwright-security.config.ts playwright.config.ts

# Step 4: 复制测试用例
cp -r e2e/security/ ./e2e/security/
```

### 运行测试

```bash
# 运行所有安全测试
npx playwright test --config=playwright-security.config.ts

# 运行特定类型测试
npx playwright test --project=xss
npx playwright test --project=csrf
npx playwright test --project=sqli
npx playwright test --project=auth
npx playwright test --project=bola

# 运行单个测试文件
npx playwright test e2e/security/xss-test.spec.ts

# 有头模式运行（观看执行过程）
npx playwright test --headed

# 生成 HTML 报告
npx playwright show-report
```

---

## 📁 文件结构

```
project/
├── playwright-security.config.ts     # 安全测试配置
├── e2e/
│   └── security/
│       ├── xss-test.spec.ts          # XSS 攻击测试
│       ├── csrf-test.spec.ts         # CSRF 攻击测试
│       ├── sqli-test.spec.ts         # SQL 注入测试
│       ├── auth-test.spec.ts         # 认证安全测试
│       └── bola-test.spec.ts         # 越权访问测试
└── playwright-report/                 # 测试报告输出
    └── security/
        └── index.html                 # HTML 报告
```

---

## 🧪 测试用例说明

### XSS 测试 (xss-test.spec.ts)

| 测试项 | 攻击类型 | 防护验证 |
|--------|---------|---------|
| 反射型 XSS | URL 参数注入 | 输入转义 |
| 存储型 XSS | 评论区注入 | 输出编码 |
| DOM 型 XSS | Hash 注入 | DOM 净化 |
| SVG XSS | 文件上传注入 | 文件类型检查 |
| 富文本 XSS | 编辑器注入 | HTML 过滤 |
| 属性逃逸 | 引号逃逸 | 属性转义 |
| JavaScript 协议 | href 注入 | 协议过滤 |
| Data URI | data: 注入 | URI 过滤 |

### CSRF 测试 (csrf-test.spec.ts)

| 测试项 | 验证内容 |
|--------|---------|
| 登录表单 Token | 表单包含 CSRF Token |
| 缺少 Token 拒绝 | 无 Token 请求被拒绝 |
| 无效 Token 拒绝 | Token 无效被拒绝 |
| 敏感操作防护 | 修改密码、转账等需要 Token |
| AJAX 请求 Token | 请求头包含 Token |
| SameSite Cookie | Cookie 设置 SameSite 属性 |
| Referer 检查 | 验证请求来源 |
| 删除操作防护 | DELETE 请求需要 Token |

### SQL 注入测试 (sqli-test.spec.ts)

| 测试项 | 攻击类型 | 防护验证 |
|--------|---------|---------|
| 认证绕过 | 经典 SQL 注入 | 参数化查询 |
| UNION 注入 | 联合查询 | 输入过滤 |
| 盲注 | 时间延迟注入 | 响应时间监控 |
| 错误消息 | 数据库信息泄露 | 错误脱敏 |
| NoSQL 注入 | MongoDB 注入 | 类型验证 |
| 命令注入 | 系统命令执行 | 命令过滤 |
| LDAP 注入 | 目录服务注入 | 输入验证 |
| XXE 注入 | XML 外部实体 | XML 解析配置 |
| SSTI 注入 | 模板注入 | 模板引擎配置 |
| 路径遍历 | 文件路径注入 | 路径验证 |

### 认证安全测试 (auth-test.spec.ts)

| 测试项 | 攻击类型 | 防护验证 |
|--------|---------|---------|
| Token 过期 | 过期 Token 重用 | Token 有效期验证 |
| Token 重用 | 跨设备 Token 重用 | 设备指纹绑定 |
| 会话固定 | Session 固定攻击 | 登录后更新 Session |
| 暴力破解 | 密码暴力猜测 | 速率限制、账户锁定 |
| 弱密码 | 弱密码注册 | 密码策略 |
| 多设备登录 | 异地登录检测 | 登录通知 |
| 登出失效 | 登出后 Token 重用 | Token 作废 |
| JWT 签名 | 伪造 JWT Token | 签名验证 |
| 重置 Token | 密码重置 Token | Token 有效性 |
| 2FA | 双因素认证 | 敏感操作验证 |

### BOLA 测试 (bola-test.spec.ts)

| 测试项 | 攻击类型 | 防护验证 |
|--------|---------|---------|
| 水平越权 | 访问其他用户资料 | 所有权验证 |
| 修改越权 | 修改其他用户资料 | 写权限验证 |
| 订单越权 | 查看其他用户订单 | 关系验证 |
| 消息越权 | 查看其他用户消息 | 隐私权限 |
| 垂直越权 | 访问管理员接口 | 角色验证 |
| 删除越权 | 删除系统资源 | 删除权限 |
| ID 枚举 | 枚举 ID 获取数据 | 访问控制 |
| UUID 猜测 | 猜测 UUID 访问 | 随机 ID |
| 批量操作 | 批量修改越权 | 批量权限检查 |
| 文件越权 | 下载其他用户文件 | 文件权限 |

---

## 🔧 配置选项

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `BASE_URL` | 被测应用地址 | http://localhost:3000 |
| `CI` | CI/CD 模式 | false |

### 浏览器配置

```typescript
// playwright-security.config.ts
export default defineConfig({
  // ...
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
```

---

## 📊 测试报告

### HTML 报告

```bash
# 查看 HTML 报告
npx playwright show-report
```

报告包含：
- 测试通过率
- 每个测试的详细信息
- 失败截图
- 执行视频
- 错误堆栈

### JSON 报告

```bash
# JSON 报告位置
test-results/security-results.json
```

用于 CI/CD 集成和数据分析。

### JUnit 报告

```bash
# JUnit 报告位置
test-results/security-junit.xml
```

用于 Jenkins、GitLab CI 等 CI/CD 平台。

---

## 🔗 与 Shannon 集成

Shannon 是 AI 驱动的自主渗透测试工具，可以补充 Playwright 测试：

```bash
# Step 1: 运行 Playwright 安全测试
npx playwright test --config=playwright-security.config.ts

# Step 2: 运行 Shannon AI 渗透测试
cd /opt/shannon
./shannon start URL=http://localhost:3000 REPO=.

# Step 3: 对比两份报告
# - Playwright: 预定义测试用例
# - Shannon: AI 自主发现漏洞
```

**差异对比**：

| 维度 | Playwright | Shannon |
|------|-----------|---------|
| 测试类型 | 预定义用例 | AI 自主探索 |
| 覆盖率 | 已知漏洞模式 | 未知漏洞发现 |
| 执行速度 | 快（几分钟） | 慢（30-90 分钟） |
| PoC 生成 | 手动编写 | 自动生成 |
| 适合场景 | 回归测试 | 深度渗透 |

---

## 🛡️ 安全测试检查清单

在执行完所有测试后，使用以下清单验证：

```markdown
# 安全测试检查清单

## XSS 防护
- [ ] 所有输入点都进行了转义
- [ ] 所有输出点都进行了编码
- [ ] 富文本编辑器有白名单过滤
- [ ] Content-Security-Policy 头已设置

## CSRF 防护
- [ ] 所有表单都有 CSRF Token
- [ ] AJAX 请求包含 Token 头
- [ ] Cookie 设置了 SameSite 属性
- [ ] Referer 验证已启用

## SQL 注入防护
- [ ] 使用参数化查询
- [ ] ORM 正确配置
- [ ] 错误消息脱敏
- [ ] 输入验证白名单

## 认证安全
- [ ] Token 有效期合理（<24 小时）
- [ ] 密码策略强制要求
- [ ] 暴力破解防护启用
- [ ] 会话管理安全

## 授权安全
- [ ] 水平越权检查
- [ ] 垂直越权检查
- [ ] API 权限验证
- [ ] 资源所有权验证

## 整体评分
- 测试覆盖率：___%
- 漏洞数量：___ 个
- 严重漏洞：___ 个
- 修复优先级：___
```

---

## 📚 相关文档

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Shannon 渗透测试集成](../docs/SHANNON_INTEGRATION.md)
- [Playwright 官方文档](https://playwright.dev/)

---

## ⚠️ 免责声明

本测试套件仅供**授权的安全测试**使用。

- ✅ 在自有系统上测试
- ✅ 在获得书面授权的系统上测试
- ❌ 禁止在未授权的系统上使用
- ❌ 禁止用于非法目的

---

*版本：1.0.0*
*最后更新：2026-03-12*
*基于 OWASP Top 10 2021 + API Security Top 10 2023*
