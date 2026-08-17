# 调试与排错指南

> 子 agent 失败时的排查流程和调试技巧。

---

## 📋 目录

1. [排查流程](#-排查流程)
2. [常见问题](#-常见问题)
3. [调试工具](#-调试工具)
4. [日志分析](#-日志分析)
5. [性能分析](#-性能分析)

---

## 🔍 排查流程

### 标准排查步骤

```
1. 收集信息
   ├─ 错误日志
   ├─ 任务配置
   ├─ 系统状态
   └─ 历史记录

2. 复现问题
   ├─ 能否稳定复现？
   ├─ 最小化复现条件
   └─ 记录复现步骤

3. 定位问题
   ├─ 是环境问题？
   ├─ 是代码问题？
   ├─ 是资源问题？
   ├─ 是外部依赖问题？
   └─ 是配置问题？

4. 制定方案
   ├─ 短期：快速恢复
   └─ 长期：根本解决

5. 实施修复
   ├─ 验证修复效果
   ├─ 更新文档
   └─ 通知相关人员

6. 复盘总结
   ├─ 记录经验教训
   ├─ 更新预防措施
   └─ 优化流程
```

---

## ❓ 常见问题

### 1. 子 Agent 无响应

**症状**：子 agent 长时间无响应

**可能原因**：
- 资源不足（内存、CPU）
- 死锁或无限循环
- 网络问题
- 外部依赖超时

**排查方法**：
```bash
# 检查系统资源
top
htop

# 检查进程状态
ps aux | grep agent

# 检查网络连接
netstat -an | grep ESTABLISHED

# 查看日志
tail -f /var/log/agent.log
```

**解决方案**：
1. 增加资源限制
2. 添加超时机制
3. 优化代码逻辑
4. 检查网络连接

---

### 2. 执行结果不正确

**症状**：子 agent 执行成功但结果不符合预期

**可能原因**：
- 输入数据错误
- 逻辑错误
- 配置错误
- 环境差异

**排查方法**：
```typescript
// 添加详细日志
logger.debug('Input:', input);
logger.debug('Config:', config);
logger.debug('Intermediate result:', intermediate);
logger.debug('Final result:', result);

// 验证输入
assert(input !== null, 'Input is required');
assert(input.length > 0, 'Input cannot be empty');

// 验证输出
assert(result !== null, 'Result is required');
```

**解决方案**：
1. 验证输入数据
2. 添加中间状态日志
3. 检查配置文件
4. 确保环境一致性

---

### 3. 频繁超时

**症状**：任务经常超时

**可能原因**：
- 性能问题
- 资源竞争
- 网络延迟
- 算法复杂度高

**排查方法**：
```typescript
// 添加性能监控
const startTime = Date.now();

await heavyOperation();

const duration = Date.now() - startTime;
logger.info(`Operation took ${duration}ms`);

// 性能分析
console.profile('heavyOperation');
await heavyOperation();
console.profileEnd('heavyOperation');
```

**解决方案**：
1. 优化算法
2. 增加超时时间
3. 使用缓存
4. 分批处理

---

### 4. 内存泄漏

**症状**：内存使用持续增长

**可能原因**：
- 对象未释放
- 闭包引用
- 事件监听器未移除
- 缓存未清理

**排查方法**：
```typescript
// 内存快照
const v8 = require('v8');
const fs = require('fs');

function takeHeapSnapshot() {
  const snapshot = v8.getHeapSnapshot();
  const fileName = `heap-${Date.now()}.heapsnapshot`;
  const fileStream = fs.createWriteStream(fileName);
  snapshot.pipe(fileStream);
}

// 定期检查内存
setInterval(() => {
  const usage = process.memoryUsage();
  logger.info('Memory usage:', {
    heapUsed: `${Math.round(usage.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(usage.heapTotal / 1024 / 1024)}MB`,
  });
}, 60000);
```

**解决方案**：
1. 及时释放对象
2. 移除事件监听器
3. 清理缓存
4. 使用 WeakMap/WeakSet

---

### 5. 并发问题

**症状**：结果不一致或出现竞争条件

**可能原因**：
- 共享状态未同步
- 竞态条件
- 死锁
- 资源竞争

**排查方法**：
```typescript
// 使用锁保护共享状态
class SharedState {
  private lock = false;
  private value: any;

  async update(newValue: any): Promise<void> {
    while (this.lock) {
      await sleep(10);
    }

    this.lock = true;
    try {
      this.value = newValue;
    } finally {
      this.lock = false;
    }
  }
}

// 使用互斥锁
import { Mutex } from 'async-mutex';

const mutex = new Mutex();

async function criticalSection() {
  const release = await mutex.acquire();
  try {
    // 访问共享资源
  } finally {
    release();
  }
}
```

**解决方案**：
1. 使用锁或互斥量
2. 避免共享状态
3. 使用不可变数据
4. 合理设计并发模型

---

## 🛠️ 调试工具

### 日志工具

```typescript
// 结构化日志
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// 使用示例
logger.info('Task started', { taskId: 'task-123' });
logger.error('Task failed', { taskId: 'task-123', error: err.message });
```

### 性能分析

```typescript
// Node.js 内置性能分析
const { performance } = require('perf_hooks');

const start = performance.now();
await operation();
const end = performance.now();
console.log(`Operation took ${end - start}ms`);

// Chrome DevTools
console.profile('operation');
await operation();
console.profileEnd('operation');
```

### 内存分析

```typescript
// 堆快照
const v8 = require('v8');
const fs = require('fs');

function writeHeapSnapshot() {
  const snapshot = v8.getHeapSnapshot();
  const fileName = `heap-${Date.now()}.heapsnapshot`;
  const fileStream = fs.createWriteStream(fileName);
  snapshot.pipe(fileStream);
}

// 使用 clinic.js
// npm install -g clinic
// clinic doctor -- node app.js
// clinic heapprofiler -- node app.js
```

---

## 📊 日志分析

### 日志级别

| 级别 | 用途 | 示例 |
|------|------|------|
| ERROR | 错误信息 | 任务失败、异常 |
| WARN | 警告信息 | 性能下降、降级 |
| INFO | 一般信息 | 任务开始、完成 |
| DEBUG | 调试信息 | 中间状态、变量值 |
| TRACE | 跟踪信息 | 函数调用、流程 |

### 日志格式

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "message": "Task execution failed",
  "context": {
    "taskId": "task-123",
    "agentId": "agent-456",
    "error": {
      "type": "TIMEOUT",
      "message": "Operation timed out",
      "stackTrace": "..."
    }
  },
  "metadata": {
    "hostname": "server-01",
    "pid": 12345,
    "version": "1.0.0"
  }
}
```

### 日志分析技巧

1. **搜索关键词**：使用 grep、awk 等工具搜索特定错误
2. **统计频率**：统计错误发生的频率和分布
3. **关联分析**：关联多个日志源，找出根本原因
4. **可视化**：使用图表展示日志趋势

---

## ⚡ 性能分析

### 性能指标

| 指标 | 说明 | 工具 |
|------|------|------|
| 响应时间 | 请求处理时间 | performance.now() |
| 吞吐量 | 单位时间处理的任务数 | 自定义计数器 |
| 资源使用 | CPU、内存、磁盘 | top、htop |
| 错误率 | 失败任务占比 | 日志统计 |

### 性能优化流程

```
1. 测量基准性能
   ↓
2. 识别瓶颈
   ↓
3. 制定优化方案
   ↓
4. 实施优化
   ↓
5. 验证效果
   ↓
6. 持续监控
```

---

## 📝 最佳实践

### 预防性调试

1. **防御性编程**：验证输入、处理边界情况
2. **详细日志**：记录关键步骤和状态
3. **单元测试**：覆盖各种场景
4. **代码审查**：发现潜在问题

### 调试技巧

1. **二分法**：逐步缩小问题范围
2. **最小化复现**：找到最小复现条件
3. **对比分析**：对比正常和异常情况
4. **假设验证**：提出假设并验证

### 团队协作

1. **知识共享**：记录常见问题和解决方案
2. **代码审查**：互相检查代码
3. **配对编程**：共同解决复杂问题
4. **定期复盘**：分析故障原因
