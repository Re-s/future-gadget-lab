# 错误处理与恢复机制

> 子 agent 失败时的处理策略和恢复流程。

---

## 📋 目录

1. [错误分类](#-错误分类)
2. [重试策略](#-重试策略)
3. [降级策略](#-降级策略)
4. [异常上报](#-异常上报)
5. [故障排查流程](#-故障排查流程)

---

## 🚨 错误分类

### 按严重程度

| 级别 | 描述 | 处理方式 |
|------|------|----------|
| **P0 - 致命** | 子 agent 无法启动或立即崩溃 | 立即上报，终止任务 |
| **P1 - 严重** | 子 agent 执行失败但可恢复 | 重试或降级 |
| **P2 - 一般** | 部分功能失败，核心功能正常 | 记录日志，继续执行 |
| **P3 - 轻微** | 警告或建议性错误 | 记录日志，不影响流程 |

### 按错误类型

| 类型 | 示例 | 处理策略 |
|------|------|----------|
| **环境错误** | 依赖缺失、权限不足 | 修复环境后重试 |
| **逻辑错误** | 代码 bug、算法错误 | 修复后重试 |
| **资源错误** | 内存不足、超时 | 降级或分批处理 |
| **外部错误** | API 失败、网络问题 | 重试或降级 |
| **配置错误** | 参数错误、格式错误 | 修正配置后重试 |

---

## 🔄 重试策略

### 基础重试

```json
{
  "retry_policy": {
    "max_attempts": 3,
    "backoff": "exponential",
    "initial_delay_ms": 1000,
    "max_delay_ms": 30000,
    "retryable_errors": [
      "TIMEOUT",
      "NETWORK_ERROR",
      "RATE_LIMIT",
      "TEMPORARY_FAILURE"
    ]
  }
}
```

### 重试决策树

```
子 agent 失败
    ↓
是否可重试错误？
    ├─ 是 → 是否超过最大重试次数？
    │         ├─ 否 → 计算退避延迟 → 重试
    │         └─ 是 → 上报失败，进入降级流程
    └─ 否 → 直接上报失败，进入降级流程
```

### 重试示例

```typescript
async function executeWithRetry(
  task: Task,
  maxAttempts: number = 3,
): Promise<Result> {
  let lastError: Error;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await executeTask(task);
    } catch (error) {
      lastError = error;

      if (!isRetryable(error) || attempt === maxAttempts) {
        break;
      }

      const delay = Math.min(1000 * 2 ** attempt, 30000);
      logger.warn(`Attempt ${attempt} failed, retrying in ${delay}ms`, {
        taskId: task.id,
        error: error.message,
      });

      await sleep(delay);
    }
  }

  throw lastError;
}
```

---

## 🔽 降级策略

### 降级原则

1. **核心功能优先**：确保核心功能可用
2. **优雅降级**：提供合理的默认值或简化版本
3. **透明降级**：告知用户使用了降级方案
4. **快速恢复**：恢复正常后自动切换

### 常见降级场景

| 场景 | 降级方案 |
|------|----------|
| 子 agent 超时 | 使用缓存结果或简化处理 |
| API 限流 | 降低请求频率或使用备用 API |
| 内存不足 | 分批处理或使用流式处理 |
| 网络问题 | 使用本地缓存或离线模式 |
| 依赖失败 | 提供默认实现或跳过可选功能 |

### 降级实现示例

```typescript
async function processWithFallback(
  task: Task,
  fallback: () => Promise<Result>,
): Promise<Result> {
  try {
    return await executeTask(task);
  } catch (error) {
    logger.error('Primary execution failed, using fallback', {
      taskId: task.id,
      error: error.message,
    });

    // 记录降级事件
    await recordFallbackEvent(task.id, error);

    return fallback();
  }
}
```

---

## 📊 异常上报

### 上报级别

| 级别 | 触发条件 | 通知方式 |
|------|----------|----------|
| **CRITICAL** | 系统不可用 | 立即通知（邮件/短信） |
| **ERROR** | 功能失败 | 记录日志，定期汇总 |
| **WARNING** | 性能下降 | 记录日志 |
| **INFO** | 一般信息 | 记录日志 |

### 上报格式

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "task_id": "task-123",
  "agent_id": "agent-456",
  "error": {
    "type": "TIMEOUT",
    "message": "Task execution timed out",
    "stack_trace": "...",
    "context": {
      "task_type": "code_generation",
      "input_size": 1024,
      "retry_count": 2
    }
  },
  "recovery": {
    "attempted": true,
    "strategy": "fallback",
    "result": "success"
  }
}
```

---

## 🔍 故障排查流程

### 排查步骤

```
1. 收集信息
   ├─ 错误日志
   ├─ 任务配置
   └─ 系统状态

2. 定位问题
   ├─ 是环境问题？
   ├─ 是代码问题？
   ├─ 是资源问题？
   └─ 是外部依赖问题？

3. 制定方案
   ├─ 短期：快速恢复
   └─ 长期：根本解决

4. 实施修复
   ├─ 验证修复效果
   └─ 更新文档

5. 复盘总结
   ├─ 记录经验教训
   └─ 更新预防措施
```

### 常见故障排查表

| 症状 | 可能原因 | 排查方法 |
|------|----------|----------|
| 子 agent 无响应 | 资源不足、死锁 | 检查系统资源、日志 |
| 执行结果不正确 | 逻辑错误、数据问题 | 检查输入、输出、中间状态 |
| 频繁超时 | 性能问题、资源竞争 | 性能分析、资源监控 |
| 间歇性失败 | 网络问题、依赖不稳定 | 重试机制、降级方案 |
| 内存泄漏 | 代码缺陷、资源未释放 | 内存分析、代码审查 |

---

## 📝 最佳实践

### 预防优于治疗

1. **输入验证**：在执行前验证所有输入
2. **资源预估**：提前评估资源需求
3. **监控告警**：实时监控关键指标
4. **文档完善**：记录常见问题和解决方案

### 快速恢复

1. **自动化**：尽可能自动化恢复流程
2. **冗余设计**：关键组件有备用方案
3. **快速回滚**：出现问题能快速回滚
4. **渐进部署**：小步快跑，及时发现问题

### 持续改进

1. **定期复盘**：分析故障原因
2. **更新文档**：完善故障排查手册
3. **优化流程**：改进错误处理机制
4. **团队培训**：分享经验教训
