# 资源管理规范

> 处理大型代码库、内存限制、上下文窗口等资源约束的策略。

---

## 📋 目录

1. [上下文窗口管理](#-上下文窗口管理)
2. [大型代码库处理](#-大型代码库处理)
3. [内存管理](#-内存管理)
4. [并发控制](#-并发控制)
5. [性能优化](#-性能优化)

---

## 🧠 上下文窗口管理

### 上下文预算

| 组件 | 建议预算 | 说明 |
|------|----------|------|
| 主会话 | 20% | 用于决策、判断、汇总 |
| 子 agent | 60% | 用于执行任务 |
| 系统预留 | 20% | 用于工具调用、错误处理 |

### 上下文优化策略

#### 1. 任务拆分

```
大型任务
    ↓
拆分为多个子任务
    ↓
每个子任务 < 上下文限制
    ↓
并行执行
    ↓
汇总结果
```

#### 2. 上下文压缩

```typescript
// 压缩历史对话
function compressContext(
  messages: Message[],
  maxTokens: number,
): Message[] {
  // 保留系统消息和最近的消息
  const systemMessages = messages.filter((m) => m.role === 'system');
  const recentMessages = messages.slice(-10);

  // 合并中间消息
  const compressed = compressMessages(
    messages.slice(systemMessages.length, -10),
  );

  return [...systemMessages, ...compressed, ...recentMessages];
}
```

#### 3. 关键信息提取

```typescript
// 只保留关键信息
function extractKeyInfo(context: Context): KeyInfo {
  return {
    taskGoal: context.task.goal,
    constraints: context.task.constraints,
    deliverables: context.task.deliverables,
    // 省略详细历史
  };
}
```

---

## 📚 大型代码库处理

### 处理策略

#### 1. 分批处理

```typescript
async function processLargeCodebase(
  files: File[],
  batchSize: number = 10,
): Promise<Result[]> {
  const results: Result[] = [];

  for (let i = 0; i < files.length; i += batchSize) {
    const batch = files.slice(i, i + batchSize);
    const batchResults = await processBatch(batch);
    results.push(...batchResults);

    // 释放内存
    await sleep(100);
  }

  return results;
}
```

#### 2. 索引优先

```typescript
// 先建立索引，再按需读取
class CodebaseIndex {
  private index: Map<string, FileInfo>;

  async build(files: File[]): Promise<void> {
    for (const file of files) {
      this.index.set(file.path, {
        path: file.path,
        size: file.size,
        summary: await generateSummary(file),
      });
    }
  }

  async getRelevantFiles(query: string): Promise<File[]> {
    // 根据查询返回相关文件
    return this.search(query);
  }
}
```

#### 3. 流式处理

```typescript
// 使用流式处理大文件
async function processLargeFile(
  filePath: string,
  processor: (chunk: string) => void,
): Promise<void> {
  const stream = createReadStream(filePath, {
    encoding: 'utf-8',
    highWaterMark: 64 * 1024, // 64KB chunks
  });

  for await (const chunk of stream) {
    processor(chunk);
  }
}
```

### 文件大小限制

| 文件类型 | 建议限制 | 处理方式 |
|----------|----------|----------|
| 源代码 | < 1MB | 直接读取 |
| 文档 | < 5MB | 分批读取 |
| 日志 | < 10MB | 流式处理 |
| 二进制 | < 50MB | 分块处理 |

---

## 💾 内存管理

### 内存监控

```typescript
class MemoryMonitor {
  private threshold: number;

  constructor(thresholdMB: number = 512) {
    this.threshold = thresholdMB * 1024 * 1024;
  }

  check(): boolean {
    const usage = process.memoryUsage();
    return usage.heapUsed < this.threshold;
  }

  async waitForAvailable(): Promise<void> {
    while (!this.check()) {
      await sleep(1000);
    }
  }
}
```

### 内存优化

#### 1. 及时释放

```typescript
// 及时释放大对象
async function processData(data: LargeData): Promise<void> {
  const processed = await heavyProcessing(data);

  // 显式释放
  data = null;

  // 触发垃圾回收（如果需要）
  if (global.gc) {
    global.gc();
  }
}
```

#### 2. 使用流

```typescript
// 使用流处理大数据
import { pipeline } from 'stream/promises';

await pipeline(
  createReadStream('input.txt'),
  transformStream,
  createWriteStream('output.txt'),
);
```

#### 3. 对象池

```typescript
// 重用对象，减少分配
class ObjectPool<T> {
  private pool: T[] = [];
  private factory: () => T;

  constructor(factory: () => T, size: number = 10) {
    this.factory = factory;
    for (let i = 0; i < size; i++) {
      this.pool.push(factory());
    }
  }

  acquire(): T {
    return this.pool.pop() || this.factory();
  }

  release(obj: T): void {
    this.pool.push(obj);
  }
}
```

---

## 🔀 并发控制

### 并发限制

```typescript
class ConcurrencyLimiter {
  private running: number = 0;
  private queue: (() => void)[] = [];

  constructor(private maxConcurrent: number = 5) {}

  async run<T>(task: () => Promise<T>): Promise<T> {
    while (this.running >= this.maxConcurrent) {
      await new Promise<void>((resolve) => this.queue.push(resolve));
    }

    this.running++;
    try {
      return await task();
    } finally {
      this.running--;
      const next = this.queue.shift();
      if (next) next();
    }
  }
}
```

### 并发策略

| 场景 | 策略 | 说明 |
|------|------|------|
| 独立任务 | 完全并行 | 无依赖，可同时执行 |
| 顺序任务 | 串行执行 | 有依赖，按顺序执行 |
| 批量任务 | 分批并行 | 分批次，每批内并行 |
| 资源竞争 | 限流 | 控制并发数，避免资源耗尽 |

---

## ⚡ 性能优化

### 优化原则

1. **测量优先**：先测量，再优化
2. **瓶颈定位**：找到真正的瓶颈
3. **适度优化**：不过度优化
4. **持续监控**：优化后持续监控

### 常见优化手段

#### 1. 缓存

```typescript
class Cache<K, V> {
  private cache = new Map<K, { value: V; expiry: number }>();

  set(key: K, value: V, ttlMs: number = 60000): void {
    this.cache.set(key, {
      value,
      expiry: Date.now() + ttlMs,
    });
  }

  get(key: K): V | undefined {
    const item = this.cache.get(key);
    if (!item) return undefined;

    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return undefined;
    }

    return item.value;
  }
}
```

#### 2. 懒加载

```typescript
// 延迟加载非关键资源
class LazyLoader {
  private loaded = false;
  private resource: Resource | null = null;

  async load(): Promise<Resource> {
    if (!this.loaded) {
      this.resource = await heavyLoad();
      this.loaded = true;
    }
    return this.resource!;
  }
}
```

#### 3. 批处理

```typescript
// 批量处理，减少开销
async function batchProcess<T, R>(
  items: T[],
  processor: (batch: T[]) => Promise<R[]>,
  batchSize: number = 100,
): Promise<R[]> {
  const results: R[] = [];

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const batchResults = await processor(batch);
    results.push(...batchResults);
  }

  return results;
}
```

---

## 📊 监控指标

### 关键指标

| 指标 | 说明 | 告警阈值 |
|------|------|----------|
| 内存使用率 | 当前内存占用 | > 80% |
| CPU 使用率 | 当前 CPU 占用 | > 90% |
| 任务队列长度 | 等待执行的任务数 | > 100 |
| 平均响应时间 | 任务平均执行时间 | > 30s |
| 错误率 | 失败任务占比 | > 5% |

### 监控实现

```typescript
class MetricsCollector {
  private metrics: Map<string, number[]> = new Map();

  record(name: string, value: number): void {
    if (!this.metrics.has(name)) {
      this.metrics.set(name, []);
    }
    this.metrics.get(name)!.push(value);
  }

  getStats(name: string): Stats {
    const values = this.metrics.get(name) || [];
    return {
      count: values.length,
      min: Math.min(...values),
      max: Math.max(...values),
      avg: values.reduce((a, b) => a + b, 0) / values.length,
    };
  }
}
```

---

## 📝 最佳实践

### 预防性措施

1. **预估资源需求**：提前评估任务资源消耗
2. **设置资源限制**：为每个任务设置资源上限
3. **监控资源使用**：实时监控资源使用情况
4. **优雅降级**：资源不足时优雅降级

### 应急措施

1. **快速释放**：发现资源不足时快速释放
2. **任务取消**：取消非关键任务
3. **扩容**：必要时增加资源
4. **告警通知**：及时通知相关人员
