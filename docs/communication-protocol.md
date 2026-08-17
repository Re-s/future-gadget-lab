# Agent 通信协议规范

> 定义子 agent 与主会话之间的通信格式和流程。

---

## 📋 目录

1. [通信模型](#-通信模型)
2. [消息格式](#-消息格式)
3. [汇报流程](#-汇报流程)
4. [结果格式](#-结果格式)
5. [状态同步](#-状态同步)

---

## 🌐 通信模型

### 基本模型

```
┌─────────────┐         ┌─────────────┐
│   主会话    │ ←─────→ │   子 Agent  │
│  (指挥中枢) │  消息   │  (执行单元) │
└─────────────┘         └─────────────┘
       ↑
       │ 汇报
       ↓
┌─────────────┐
│    用户     │
└─────────────┘
```

### 通信原则

1. **异步优先**：子 agent 默认后台运行，不阻塞主会话
2. **明确状态**：每个任务有明确的状态（pending/running/success/failed）
3. **结构化汇报**：使用统一的格式汇报结果
4. **错误透明**：失败时提供完整的错误信息

---

## 📨 消息格式

### 任务分发消息

```json
{
  "message_type": "task_dispatch",
  "task_id": "task-123",
  "timestamp": "2024-01-15T10:00:00Z",
  "sender": "main_session",
  "receiver": "agent-456",
  "payload": {
    "task_type": "code_generation",
    "description": "生成用户认证模块",
    "background": {
      "project": "my-app",
      "tech_stack": "TypeScript + Node",
      "dependencies": ["express", "jsonwebtoken"]
    },
    "requirements": {
      "inputs": ["用户需求文档", "API 接口定义"],
      "outputs": ["src/auth/", "tests/auth/"],
      "constraints": ["遵循单一职责", "覆盖率 ≥ 80%"]
    },
    "deadline": "2024-01-15T12:00:00Z",
    "priority": "high"
  }
}
```

### 进度汇报消息

```json
{
  "message_type": "progress_update",
  "task_id": "task-123",
  "timestamp": "2024-01-15T10:30:00Z",
  "sender": "agent-456",
  "receiver": "main_session",
  "payload": {
    "status": "running",
    "progress": 50,
    "current_step": "编写测试用例",
    "estimated_completion": "2024-01-15T11:30:00Z",
    "issues": []
  }
}
```

### 结果汇报消息

```json
{
  "message_type": "task_result",
  "task_id": "task-123",
  "timestamp": "2024-01-15T11:30:00Z",
  "sender": "agent-456",
  "receiver": "main_session",
  "payload": {
    "status": "success",
    "deliverables": [
      {
        "path": "src/auth/auth.service.ts",
        "type": "file",
        "description": "认证服务"
      },
      {
        "path": "src/auth/auth.controller.ts",
        "type": "file",
        "description": "认证控制器"
      },
      {
        "path": "tests/auth/auth.test.ts",
        "type": "file",
        "description": "认证测试"
      }
    ],
    "metrics": {
      "duration_ms": 5400000,
      "files_created": 5,
      "lines_of_code": 350,
      "test_coverage": 85
    },
    "notes": "已完成所有要求，测试通过"
  }
}
```

### 错误汇报消息

```json
{
  "message_type": "task_result",
  "task_id": "task-123",
  "timestamp": "2024-01-15T11:30:00Z",
  "sender": "agent-456",
  "receiver": "main_session",
  "payload": {
    "status": "failed",
    "error": {
      "type": "DEPENDENCY_MISSING",
      "message": "缺少依赖: express",
      "stack_trace": "...",
      "context": {
        "attempted_fix": "npm install express",
        "retry_count": 2
      }
    },
    "partial_results": [],
    "recovery_suggestion": "请先安装依赖，然后重试"
  }
}
```

---

## 📊 汇报流程

### 正常流程

```
任务分发
    ↓
子 Agent 接收任务
    ↓
开始执行 → 发送进度更新（可选）
    ↓
执行完成
    ↓
发送结果汇报
    ↓
主会话接收并处理
```

### 失败流程

```
任务分发
    ↓
子 Agent 接收任务
    ↓
开始执行
    ↓
遇到错误
    ↓
是否可恢复？
    ├─ 是 → 尝试恢复 → 继续执行
    └─ 否 → 发送错误汇报 → 任务终止
```

---

## 📦 结果格式

### 文件交付

```json
{
  "deliverables": [
    {
      "path": "src/auth/auth.service.ts",
      "type": "file",
      "description": "认证服务",
      "size_bytes": 2048,
      "checksum": "sha256:..."
    }
  ]
}
```

### 文档交付

```json
{
  "deliverables": [
    {
      "path": "docs/api.md",
      "type": "document",
      "description": "API 文档",
      "format": "markdown"
    }
  ]
}
```

### 报告交付

```json
{
  "deliverables": [
    {
      "path": "reports/test-report.html",
      "type": "report",
      "description": "测试报告",
      "format": "html"
    }
  ]
}
```

---

## 🔄 状态同步

### 状态定义

| 状态 | 描述 | 说明 |
|------|------|------|
| `pending` | 待执行 | 任务已创建，等待分发 |
| `dispatched` | 已分发 | 任务已发送给子 agent |
| `running` | 执行中 | 子 agent 正在执行 |
| `success` | 成功 | 任务成功完成 |
| `failed` | 失败 | 任务执行失败 |
| `cancelled` | 已取消 | 任务被取消 |
| `timeout` | 超时 | 任务执行超时 |

### 状态转换

```
pending → dispatched → running → success
                     ↓
                   failed
                     ↓
                  cancelled
                     ↓
                   timeout
```

### 状态查询

主会话可以随时查询子 agent 状态：

```json
{
  "message_type": "status_query",
  "task_id": "task-123",
  "timestamp": "2024-01-15T10:30:00Z",
  "sender": "main_session",
  "receiver": "agent-456"
}
```

响应：

```json
{
  "message_type": "status_response",
  "task_id": "task-123",
  "timestamp": "2024-01-15T10:30:01Z",
  "sender": "agent-456",
  "receiver": "main_session",
  "payload": {
    "status": "running",
    "progress": 75,
    "current_step": "生成测试用例",
    "estimated_completion": "2024-01-15T11:15:00Z"
  }
}
```

---

## 📝 最佳实践

### 消息设计

1. **自包含**：消息包含所有必要信息
2. **版本化**：消息格式有版本号，便于升级
3. **可扩展**：预留扩展字段
4. **可追踪**：每条消息有唯一 ID

### 错误处理

1. **明确错误类型**：使用标准错误代码
2. **提供上下文**：包含足够的调试信息
3. **建议恢复方案**：提供可行的解决方案
4. **保留现场**：保存错误发生时的状态

### 性能优化

1. **批量汇报**：多个小任务可以批量汇报
2. **增量更新**：只汇报变化的部分
3. **压缩传输**：大数据量时使用压缩
4. **异步处理**：非关键消息异步处理
