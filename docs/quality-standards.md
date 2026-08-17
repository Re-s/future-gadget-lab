# 代码质量规范

> 详细的质量标准和最佳实践。

## 目录

1. [执行原则](#-执行原则主会话待命)
2. [命名规范](#-命名规范)
3. [代码风格](#-代码风格)
4. [注释规范](#-注释规范)
5. [错误处理](#-错误处理)
6. [函数调用日志](#-函数调用日志)
7. [依赖管理](#-依赖管理)
8. [测试规范](#-测试规范)
9. [安全规范](#-安全规范)

---

## 🎯 执行原则：主会话待命

> **主会话是指挥中枢，不是执行单元。**

### 核心规则

```yaml
execution_policy:
  main_session_role: "Decompose → Dispatch → Synthesize"
  forbidden:
    - 直接执行业务代码
    - 直接运行构建/测试
    - 直接处理耗时操作
  required:
    - 所有任务下发到子 agent
    - 子 agent 必须自包含（看不到主会话上下文）
    - 子 agent 默认后台运行
```

### 子 Agent Prompt 模板

```
你是 [角色]，负责完成以下任务：

## 背景
[项目背景和技术栈]

## 任务
[具体要做什么]

## 约束
[技术限制、编码规范]

## 交付物
[明确的输出格式和验收标准]
```

### 为什么这样做？

1. **保持响应**：主会话卡住 = 用户无法交互
2. **并行执行**：多个子 agent 同时工作，效率翻倍
3. **Token 经济**：主会话上下文是稀缺资源，省下来做判断
4. **错误隔离**：子 agent 失败不影响主会话状态

---

## 📝 命名规范

### 通用原则

- **清晰性**：名称应明确表达意图，避免缩写
- **一致性**：同一项目内保持统一风格
- **可发音**：便于口头讨论

### 语言特定规则

| 语言 | 变量 | 函数 | 类 | 文件 |
|------|------|------|-----|------|
| JavaScript/TypeScript | camelCase | camelCase (动词开头) | PascalCase | kebab-case |
| Python | snake_case | snake_case (动词开头) | PascalCase | snake_case |
| Rust | snake_case | snake_case | PascalCase | snake_case |
| Go | camelCase | PascalCase (导出) / camelCase | PascalCase | snake_case |

### 示例

```typescript
// ✅ 好的命名
const userAuthentication = async (credentials: Credentials): Promise<User> => { ... }
class DataProcessor { ... }
const MAX_RETRY_COUNT = 3;

// ❌ 不好的命名
const u = async (c) => { ... }  // 太短，无意义
const processTheDataNow = () => { ... }  // 冗余
const data = []  // 太泛
```

---

## 🎨 代码风格

### 格式化

- 使用项目配置的格式化工具（Prettier/Black/rustfmt）
- 提交前自动格式化（通过 Git Hooks）
- 编辑器配置（`.editorconfig`）确保一致性

### 结构

```typescript
// ✅ 函数结构示例
function calculateTotalPrice(
  items: CartItem[],
  discount: number,
): number {
  // 1. 输入验证
  if (discount < 0 || discount > 1) {
    throw new Error('Discount must be between 0 and 1');
  }

  // 2. 核心逻辑
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const discountAmount = subtotal * discount;

  // 3. 返回结果
  return subtotal - discountAmount;
}
```

### 原则

1. **单一职责**：每个函数/类只做一件事
2. **DRY**：不重复自己
3. **KISS**：保持简单
4. **YAGNI**：不过度设计

---

## 💬 注释规范

### 何时注释

| ✅ 必须注释 | ❌ 禁止注释 |
|-------------|-------------|
| 复杂算法 | 注释掉的代码 |
| 业务规则 | 无意义的 // TODO |
| Hack/Workaround | 重复文档的注释 |
| 非显而易见的设计决策 | // 变量声明 |

### 注释风格

```typescript
// ✅ 解释 Why，而非 What
// 使用位运算而非乘法，因为这是性能关键路径
// 且输入范围保证在 32 位整数内
const result = value << 2;

// ❌ 解释 What（冗余）
// 将 value 左移 2 位
const result = value << 2;

// ✅ 文档注释
/**
 * 计算购物车总价
 * @param items - 购物车商品列表
 * @param discount - 折扣比例 (0-1)
 * @returns 折后总价
 * @throws {Error} 当折扣超出有效范围时
 */
function calculateTotalPrice(
  items: CartItem[],
  discount: number,
): number { ... }
```

---

## ⚠️ 错误处理

### 原则

1. **不要静默吞错**：捕获异常后必须处理或重新抛出
2. **错误分级**：ERROR / WARN / INFO
3. **提供上下文**：错误信息应包含足够的诊断信息

### 模式选择

```typescript
// TypeScript: Result 模式（推荐用于可恢复错误）
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

async function fetchUser(id: string): Promise<Result<User, ApiError>> {
  try {
    const response = await api.get(`/users/${id}`);
    return { ok: true, value: response.data };
  } catch (error) {
    return { ok: false, error: { code: 'FETCH_FAILED', message: error.message } };
  }
}

// ❌ 禁止静默吞错
try {
  await riskyOperation();
} catch (e) {
  // 什么都不做 ← 最糟糕的错误处理
}

// ✅ 至少记录日志
try {
  await riskyOperation();
} catch (e) {
  logger.error('Operation failed', { error: e, context: '...' });
}
```

---

## 📡 函数调用日志

> **开发与验证阶段，尽可能输出所有函数调用日志，以备跟踪测试。**

### 目的

1. **跟踪执行路径**：验证实际调用链与设计一致
2. **快速定位故障**：还原调用序列，找到问题函数
3. **性能观测**：量化函数耗时，发现瓶颈

### 覆盖范围

| 阶段 | 要求 |
|------|------|
| 开发阶段 | 全量输出函数调用日志 |
| 验证阶段 | 全量输出，配合测试用例跟踪 |
| 生产环境 | 默认关闭，通过配置开关按需开启 |

### 日志级别

| 级别 | 记录内容 |
|------|----------|
| `TRACE` | 函数入口/出口、参数、返回值 |
| `DEBUG` | 关键分支、状态变化、中间结果 |

### 每条函数日志应包含

```typescript
// 入口日志
logger.trace('func_enter', {
  task_id: 'task-123',
  function: 'calculateTotalPrice',
  caller: 'checkoutService.createOrder',
  args: { itemCount: 3, hasDiscount: true },  // 关键参数摘要，敏感字段脱敏
});

// 出口日志
logger.trace('func_exit', {
  task_id: 'task-123',
  function: 'calculateTotalPrice',
  duration_ms: 12,
  result: { total: 299.5 },  // 返回值摘要
});
```

### 规范要点

| # | 要求 |
|---|------|
| 1 | 每个函数入口记录：函数名、调用者、关键参数摘要 |
| 2 | 每个函数出口记录：返回值摘要或异常信息 |
| 3 | 记录函数耗时，超过阈值（如 >100ms）单独标记 |
| 4 | 日志统一 JSON 结构化，携带调用链标识（task_id/request_id） |
| 5 | 敏感数据脱敏：密码、token、密钥、个人数据一律不落日志 |

### 平衡原则

- **性能敏感路径**（热循环、高频调用）：使用采样或摘要日志，避免日志本身成为瓶颈
- **完整跟踪 vs 性能**：开发/验证阶段追求完整，生产阶段追求低开销
- **可配置**：日志详细度通过配置开关控制（`LOG_LEVEL` / `TRACE_ENABLED`）

### 反例

```typescript
// ❌ 只记一句话，无法定位问题
logger.debug('done');

// ❌ 记录敏感数据
logger.trace('login', { password: userInput.password });  // 绝对禁止

// ❌ 手动开关未接配置，上线后关不掉
logger.log('calculateTotalPrice', total);  // 生产环境也输出，性能爆炸
```

---

## 📦 依赖管理

### 原则

1. **最小化**：只引入必要的依赖
2. **评估**：检查维护状态、下载量、CVE
3. **锁定**：提交 lockfile

### 依赖评估清单

- [ ] 最近一次发布 < 6 个月
- [ ] 周下载量 > 10,000（核心依赖）
- [ ] 无已知高危 CVE
- [ ] 许可证兼容
- [ ] 社区活跃（issues、PR）

### 更新策略

```bash
# 检查过期依赖
pnpm outdated

# 安全审计
pnpm audit

# 自动更新（建议使用 Dependabot/Renovate）
pnpm update --interactive
```

---

## 🧪 测试规范

### 测试金字塔

```
        ┌───────────┐
        │   E2E    │  少量，验证关键路径
        │  (10%)   │
        ├───────────┤
        │Integration│  适量，验证模块交互
        │  (30%)   │
        ├───────────┤
        │   Unit   │  大量，验证独立逻辑
        │  (60%)   │
        └───────────┘
```

### 命名约定

```typescript
// 格式：描述行为 + 条件 + 预期结果
describe('calculateTotalPrice', () => {
  it('should apply discount correctly when discount is valid', () => { ... });
  it('should throw error when discount is negative', () => { ... });
  it('should return 0 when cart is empty', () => { ... });
});
```

### 覆盖率目标

| 指标 | 最低目标 | 理想目标 |
|------|----------|----------|
| 行覆盖率 | 80% | 90%+ |
| 分支覆盖率 | 75% | 85%+ |
| 函数覆盖率 | 80% | 95%+ |

---

## 🔒 安全规范

### OWASP Top 10 检查清单

- [ ] **注入**：使用参数化查询，验证所有输入
- [ ] **认证**：安全的密码存储（bcrypt/argon2）
- [ ] **敏感数据**：加密存储，不硬编码
- [ ] **访问控制**：最小权限原则
- [ ] **配置**：默认安全配置
- [ ] **依赖**：定期漏洞扫描

### 敏感信息处理

```typescript
// ❌ 绝对禁止
const API_KEY = 'sk-1234567890';
const DB_PASSWORD = 'password123';

// ✅ 使用环境变量
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY environment variable is required');
}
```

---

## 📚 参考资料

- [Google Engineering Practices](https://google.github.io/eng-practices/)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Python PEP 8](https://peps.python.org/pep-0008/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
