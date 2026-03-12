/**
 * BOLA（对象级别授权破坏）安全测试
 * 以前称为 IDOR（不安全的直接对象引用）
 *
 * 测试目标：验证系统防止越权访问
 * OWASP API Security Top 10: API1:2023 - Broken Object Level Authorization
 */

import { test, expect } from '@playwright/test';

test.describe('BOLA 越权访问测试', () => {
  let user1Token: string;
  let user2Token: string;
  let user1Id: string;
  let user2Id: string;

  /**
   * 前置步骤：创建两个测试用户并登录
   */
  test.beforeEach(async ({ page, request }) => {
    // 用户 1 登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'user1');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    const cookies1 = await page.context().cookies();
    const token1 = cookies1.find((c) => c.name === 'auth_token');
    user1Token = token1?.value || '';
    user1Id = '1';

    // 登出
    await page.click('button:has-text("登出")');
    await page.waitForLoadState('networkidle');

    // 用户 2 登录
    await page.goto('/login');
    await page.fill('input[name="username"]', 'user2');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForLoadState('networkidle');

    const cookies2 = await page.context().cookies();
    const token2 = cookies2.find((c) => c.name === 'auth_token');
    user2Token = token2?.value || '';
    user2Id = '2';
  });

  /**
   * 测试 1: 水平越权 - 访问其他用户资料
   * 用户 2 尝试访问用户 1 的个人资料
   */
  test('应防止水平越权访问其他用户资料', async ({ request }) => {
    // 用户 2 尝试访问用户 1 的资料
    const response = await request.get(`/api/users/${user1Id}`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|access.*denied/);
  });

  /**
   * 测试 2: 水平越权 - 修改其他用户资料
   * 用户 2 尝试修改用户 1 的个人信息
   */
  test('应防止水平越权修改其他用户资料', async ({ request }) => {
    const updateData = {
      name: 'Hacked by User2',
      email: 'hacker@example.com',
    };

    // 用户 2 尝试修改用户 1 的资料
    const response = await request.put(`/api/users/${user1Id}`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
        'Content-Type': 'application/json',
      },
      data: updateData,
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|access.*denied/);
  });

  /**
   * 测试 3: 水平越权 - 查看其他用户订单
   * 用户 2 尝试查看用户 1 的订单列表
   */
  test('应防止水平越权查看其他用户订单', async ({ request }) => {
    // 用户 2 尝试查看用户 1 的订单
    const response = await request.get(`/api/users/${user1Id}/orders`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|access.*denied/);
  });

  /**
   * 测试 4: 水平越权 - 访问其他用户消息
   * 用户 2 尝试查看用户 1 的私信
   */
  test('应防止水平越权查看其他用户消息', async ({ request }) => {
    // 用户 2 尝试查看用户 1 的消息
    const response = await request.get(`/api/users/${user1Id}/messages`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|access.*denied/);
  });

  /**
   * 测试 5: 垂直越权 - 普通用户访问管理员接口
   * 普通用户尝试访问管理员专属功能
   */
  test('应防止垂直越权访问管理员接口', async ({ request }) => {
    // 普通用户尝试访问管理员用户列表
    const response = await request.get('/api/admin/users', {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|admin.*required|role.*required/);
  });

  /**
   * 测试 6: 垂直越权 - 普通用户删除资源
   * 普通用户尝试删除系统资源
   */
  test('应防止垂直越权删除资源', async ({ request }) => {
    const resourceId = '1';

    // 普通用户尝试删除资源
    const response = await request.delete(`/api/admin/resources/${resourceId}`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden|admin.*required/);
  });

  /**
   * 测试 7: ID 枚举攻击
   * 尝试通过枚举 ID 获取其他用户数据
   */
  test('应防止 ID 枚举攻击', async ({ request }) => {
    const accessibleIds: number[] = [];

    // 尝试枚举 ID 从 1 到 100
    for (let i = 1; i <= 100; i++) {
      const response = await request.get(`/api/users/${i}`, {
        headers: {
          Authorization: `Bearer ${user2Token}`,
        },
      });

      if (response.status() === 200) {
        const body = await response.json();
        // 只能访问自己的数据
        if (body.id === parseInt(user2Id)) {
          accessibleIds.push(i);
        } else {
          // 如果能访问其他用户数据，测试失败
          throw new Error(`BOLA 漏洞：用户 2 可以访问用户${i}的数据`);
        }
      }
    }

    // 验证只能访问自己的数据
    expect(accessibleIds).toEqual([parseInt(user2Id)]);
  });

  /**
   * 测试 8: UUID 猜测攻击
   * 尝试通过猜测 UUID 访问其他用户资源
   */
  test('应防止 UUID 猜测攻击', async ({ request }) => {
    // 尝试使用常见 UUID 模式访问
    const testUuids = [
      '00000000-0000-0000-0000-000000000001',
      'ffffffff-ffff-ffff-ffff-ffffffffffff',
      '12345678-1234-1234-1234-123456789abc',
    ];

    for (const uuid of testUuids) {
      const response = await request.get(`/api/resources/${uuid}`, {
        headers: {
          Authorization: `Bearer ${user2Token}`,
        },
      });

      // 验证被拒绝（404 或 403）
      expect(response.status()).toMatch(/403|404/);
    }
  });

  /**
   * 测试 9: 批量操作越权
   * 尝试通过批量操作修改其他用户数据
   */
  test('应防止批量操作越权', async ({ request }) => {
    const batchData = {
      ids: [user1Id, '999', '1000'], // 包含其他用户 ID
      action: 'delete',
    };

    // 用户 2 尝试批量删除（包含用户 1 的资源）
    const response = await request.post('/api/resources/batch-delete', {
      headers: {
        Authorization: `Bearer ${user2Token}`,
        'Content-Type': 'application/json',
      },
      data: batchData,
    });

    // 验证操作被拒绝
    expect(response.status()).toMatch(/401|403/);

    const body = await response.json();
    expect(body.error).toMatch(/unauthorized|forbidden/);
  });

  /**
   * 测试 10: 关系型越权
   * 尝试通过关系 ID 访问其他用户的相关资源
   */
  test('应防止关系型越权访问', async ({ request }) => {
    // 用户 2 尝试访问用户 1 的评论
    const response = await request.get(`/api/posts/1/comments`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 如果是公开评论，应该可以访问
    // 但如果是私有评论，应该被拒绝
    // 这里验证响应包含权限检查逻辑
    const body = await response.json();

    // 检查响应中是否有权限过滤
    if (body.comments) {
      for (const comment of body.comments) {
        // 用户 2 不应该看到用户 1 的私有评论
        if (comment.isPrivate) {
          expect(comment.authorId).not.toBe(parseInt(user1Id));
        }
      }
    }
  });

  /**
   * 测试 11: 文件访问越权
   * 尝试下载其他用户的文件
   */
  test('应防止越权访问其他用户文件', async ({ request }) => {
    // 用户 2 尝试下载用户 1 的文件
    const response = await request.get(`/api/files/download?fileId=${user1Id}`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝
    expect(response.status()).toMatch(/401|403|404/);
  });

  /**
   * 测试 12: API 参数篡改越权
   * 尝试通过修改 API 参数越权访问
   */
  test('应防止参数篡改越权', async ({ request }) => {
    // 用户 2 尝试通过 user_id 参数访问用户 1 的数据
    const response = await request.get(`/api/profile?user_id=${user1Id}`, {
      headers: {
        Authorization: `Bearer ${user2Token}`,
      },
    });

    // 验证被拒绝或返回当前用户数据
    expect(response.status()).toMatch(/200|401|403/);

    if (response.status() === 200) {
      const body = await response.json();
      // 如果返回 200，必须是用户 2 自己的数据
      expect(body.id.toString()).toBe(user2Id);
    }
  });
});
