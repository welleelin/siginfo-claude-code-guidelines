# API 清单模板

> 在进行 API 测试之前，使用此模板列出所有需要的 API，并检查完整性。

## 使用方法

1. 复制此模板到项目根目录，命名为 `api-checklist.md`
2. 根据需求文档填写所有 API
3. 运行检查脚本：`./scripts/check-api-completeness.sh api-checklist.md`
4. 根据报告决定是否继续测试

## API 清单格式

```markdown
- [ ] METHOD /api/path - API 描述
```

- `[ ]` 表示未完成
- `[x]` 表示已完成
- `METHOD` 是 HTTP 方法（GET/POST/PUT/DELETE）
- `/api/path` 是 API 路径
- `API 描述` 是功能说明

---

## 示例：用户认证模块

### 认证相关

- [ ] POST /api/auth/register - 用户注册
- [ ] POST /api/auth/login - 用户登录
- [ ] POST /api/auth/logout - 用户登出
- [ ] GET /api/auth/verify - 验证 Token
- [ ] POST /api/auth/refresh - 刷新 Token
- [ ] POST /api/auth/forgot-password - 忘记密码
- [ ] POST /api/auth/reset-password - 重置密码

### 用户信息

- [ ] GET /api/user/profile - 获取用户信息
- [ ] PUT /api/user/profile - 更新用户信息
- [ ] PUT /api/user/password - 修改密码
- [ ] DELETE /api/user/account - 删除账号

---

## 示例：电商模块

### 商品管理

- [ ] GET /api/products - 获取商品列表
- [ ] GET /api/products/:id - 获取商品详情
- [ ] POST /api/products - 创建商品（管理员）
- [ ] PUT /api/products/:id - 更新商品（管理员）
- [ ] DELETE /api/products/:id - 删除商品（管理员）

### 购物车

- [ ] GET /api/cart - 获取购物车
- [ ] POST /api/cart/items - 添加商品到购物车
- [ ] PUT /api/cart/items/:id - 更新购物车商品数量
- [ ] DELETE /api/cart/items/:id - 从购物车删除商品
- [ ] DELETE /api/cart - 清空购物车

### 订单管理

- [ ] GET /api/orders - 获取订单列表
- [ ] GET /api/orders/:id - 获取订单详情
- [ ] POST /api/orders - 创建订单
- [ ] PUT /api/orders/:id/cancel - 取消订单
- [ ] PUT /api/orders/:id/pay - 支付订单

### 支付相关

- [ ] POST /api/payment/create - 创建支付
- [ ] POST /api/payment/callback - 支付回调
- [ ] GET /api/payment/:id/status - 查询支付状态

---

## 检查清单

在标记 API 为完成（`[x]`）之前，确保：

- [ ] 路由已定义
- [ ] 控制器已实现
- [ ] 请求参数验证完整
- [ ] 响应格式正确
- [ ] 错误处理完整
- [ ] 数据库操作正确
- [ ] 单元测试已编写
- [ ] 基本功能可运行

---

## 完整性检查命令

```bash
# 检查 API 完整性
./scripts/check-api-completeness.sh api-checklist.md

# 指定 API 基础 URL
./scripts/check-api-completeness.sh api-checklist.md http://localhost:8000

# 查看帮助
./scripts/check-api-completeness.sh --help
```

---

## 报告示例

检查完成后会生成报告：

```markdown
# API 完整性检查报告

**检查时间**：2026-03-07 10:00:00
**API 基础 URL**：http://localhost:8000

## 检查结果

| API | 描述 | 状态 | 备注 |
|-----|------|------|------|
| POST /api/auth/login | 用户登录 | ✅ 完成 | HTTP 200 |
| GET /api/auth/verify | 验证 Token | ✅ 完成 | HTTP 200 |
| POST /api/auth/logout | 用户登出 | ⚠️ 未实现 | 需要开发 |

## 统计

| 指标 | 数量 |
|------|------|
| 总 API 数 | 3 |
| 已完成 | 2 |
| 未完成 | 1 |
| 完成率 | 67% |

## 决策

⚠️ **建议标记 Mock 后继续测试**
- 核心 API 已完成（2/3）
- 未完成的 API 需要标记为 Mock
- 后续替换为真实 API
```

---

## 注意事项

1. **核心 API 优先**：确保核心业务 API 完成后再测试
2. **及时更新**：API 开发完成后及时更新清单（`[ ]` → `[x]`）
3. **标记 Mock**：未完成的 API 必须在测试代码中标记为 Mock
4. **定期检查**：每次测试前运行检查脚本
5. **文档同步**：API 清单与 API 文档保持同步
