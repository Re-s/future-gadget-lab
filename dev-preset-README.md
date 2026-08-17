# Dev Preset - Agent 开发标准流程预设

> 一套通用的程序开发工作流，让 AI Agent 按标准流程创建新项目。

## 📋 目录

- [设计哲学](#-设计哲学)
- [流程概览](#-流程概览)
- [文件结构](#-文件结构)
- [各阶段详解](#-各阶段详解)
- [使用方法](#-使用方法)

---

## 🧪 设计哲学

1. **科学方法驱动**：假设 → 实验 → 验证 → 结论
2. **模块化**：每个阶段可独立执行、组合
3. **可扩展**：根据技术栈和项目类型灵活调整
4. **质量优先**：测试覆盖率、代码规范、安全审计
5. **主会话待命**：主会话永远保持可用，所有执行任务下发到子 agent

---

## 🎯 核心原则：主会话待命

> **主会话是指挥中枢，不是执行单元。**

### 规则

| ✅ 主会话可以做 | ❌ 主会话禁止做 |
|----------------|----------------|
| 分析需求，拆解子任务 | 直接执行业务代码 |
| 选择子 agent 配置 | 直接运行构建/测试 |
| 分发任务并跟踪 | 直接处理耗时操作 |
| 收集结果并整合 | 直接搬运文件内容 |
| 向用户汇报结论 | — |
| 处理用户决策交互 | — |

### 为什么？

1. **保持响应**：主会话卡住 = 用户无法交互
2. **并行执行**：多个子 agent 同时工作，效率翻倍
3. **Token 经济**：主会话上下文是稀缺资源，省下来做判断
4. **错误隔离**：子 agent 失败不影响主会话状态

### 执行策略

```
用户请求
    ↓
主会话（拆解 + 分发）
    ├─→ 子 Agent A（后台）──→ 完成 ──→ 汇报
    ├─→ 子 Agent B（后台）──→ 完成 ──→ 汇报
    └─→ 子 Agent C（后台）──→ 完成 ──→ 汇报
    ↓
主会话（整合 + 汇报）
    ↓
用户收到结果
```

详见 `workflow-preset.json` 中的 `execution_policy` 字段。

---

## 🔄 流程概览

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   启动     │ →  │   搭建     │ →  │   开发     │ →  │   质量     │ →  │   部署     │ →  │   维护     │
│ Initiation │    │   Setup    │    │ Development│    │   Quality  │    │   Deploy   │    │Maintenance │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
     │                  │                  │                  │                  │                  │
  需求分析          目录初始化         模块开发           代码审查           CI 流水线         依赖更新
  技术选型          工具链配置         测试策略           性能检查           发布管理          技术债务
  架构设计          文档初始化         版本控制           安全审计           环境管理          文档同步
```

---

## 📁 文件结构

```
dev-preset/
├── README.md                    # 本文件
├── workflow-preset.json         # 主流程配置（Agent 可直接读取）
├── templates/                   # 配置文件模板
│   ├── editorconfig             # .editorconfig 模板
│   ├── .prettierrc.json         # Prettier 配置
│   ├── .prettierignore          # Prettier 忽略规则
│   ├── .gitignore.template      # .gitignore 模板
│   ├── commitlint.config.js     # Commitlint 配置
│   ├── ci-github-actions.yml    # GitHub Actions CI 模板
│   └── README.template.md       # README 模板
└── docs/
    ├── quality-standards.md     # 代码质量规范详解
    ├── error-handling.md        # 错误处理与恢复机制
    ├── communication-protocol.md # Agent 通信协议规范
    ├── resource-management.md   # 资源管理规范
    ├── debugging-guide.md       # 调试与排错指南
    └── domain-knowledge.md      # 领域知识预加载规范（Deepin 等）
```

---

## 📝 各阶段详解

### 阶段 1：项目启动（Initiation）

**目标**：明确问题、范围和技术方案

| 步骤 | 内容 | 产出 |
|------|------|------|
| 需求分析 | 理解问题本质，定义范围和约束 | requirements.md |
| 技术选型 | 根据项目类型选择语言和框架 | TECH_STACK.md |
| 架构设计 | 确定目录结构、模块边界、数据流 | ARCHITECTURE.md |

**技术选型决策规则**（来自 `workflow-preset.json`）：

| 项目类型 | 推荐技术栈 |
|----------|------------|
| Web 前端 | React/Vue + TypeScript + Vite |
| Web 后端 | Node/Python + FastAPI/Nest |
| CLI 工具 | Rust/Go + clap/cobra |
| 数据管道 | Python + Airflow/Prefect |
| AI/ML | Python + PyTorch + Lightning |
| 系统工具 | Rust + tokio |
| 默认 | TypeScript + Node |

### 阶段 2：项目搭建（Setup）

**目标**：初始化项目骨架和工具链

| 步骤 | 内容 | 模板文件 |
|------|------|----------|
| 目录初始化 | 创建标准目录结构 | - |
| 工具链配置 | 编辑器、Lint、格式化、Git Hooks | `templates/*` |
| 文档初始化 | README、CONTRIBUTING、LICENSE | `templates/README.template.md` |

### 阶段 3：开发阶段（Development）

**目标**：按模块逐步实现功能

| 步骤 | 内容 | 规则 |
|------|------|------|
| 模块开发 | TDD 或接口优先 | 单一职责、模块自包含 |
| 测试策略 | Unit → Integration → E2E | 覆盖率目标 ≥ 80% |
| 版本控制 | 分支策略、提交规范 | Conventional Commits |

### 阶段 4：质量保证（Quality）

**目标**：代码审查、测试覆盖、性能与安全

| 步骤 | 内容 | 检查项 |
|------|------|--------|
| 代码审查 | 自动化 + 人工审查 | 命名、DRY、错误处理、复杂度 |
| 性能检查 | 热点路径、资源使用 | 并发安全 |
| 安全审计 | 输入验证、漏洞扫描 | 权限最小化 |

### 阶段 5：部署发布（Deploy）

**目标**：CI/CD 流水线与发布管理

| 步骤 | 内容 | 工具 |
|------|------|------|
| CI 流水线 | lint → test → build → security | GitHub Actions |
| 发布管理 | SemVer、CHANGELOG、Tag | git tag |

### 阶段 6：维护迭代（Maintenance）

**目标**：持续改进和依赖更新

| 例行任务 | 频率 |
|----------|------|
| 依赖更新 | 每周 |
| 技术债务追踪 | 持续 |
| 文档同步 | 每次变更 |
| 性能监控 | 实时 |

---

## 🚀 使用方法

### 作为 Agent 工作流

当 Agent 收到新项目开发任务时：

1. **读取** `workflow-preset.json` 获取完整流程
2. **拆解任务**：将大任务分解为可独立执行的子任务
3. **分发子 agent**：每个子任务派发给独立的子 agent
4. **等待汇报**：子 agent 完成后自动汇报结果
5. **整合结论**：主会话汇总所有结果，向用户汇报

### 各阶段的子 Agent 分发示例

| 阶段 | 子 Agent 任务 | 并行性 |
|------|---------------|--------|
| 启动 | 需求调研、技术选型调研 | 可并行 |
| 搭建 | 目录初始化、工具链配置、文档生成 | 可并行 |
| 开发 | 各模块独立开发、测试编写 | 可并行 |
| 质量 | 代码审查、性能测试、安全扫描 | 可并行 |
| 部署 | CI 配置、发布脚本 | 可并行 |
| 维护 | 依赖更新、文档同步 | 可并行 |

### 作为人类参考

开发者可以参考此预设：

- 新项目初始化时的清单
- 团队规范制定的起点
- 代码审查的检查项

---

## 📚 补充文档

| 文档 | 说明 |
|------|------|
| [docs/quality-standards.md](docs/quality-standards.md) | 代码质量规范详解 |
| [docs/error-handling.md](docs/error-handling.md) | 错误处理与恢复机制 |
| [docs/communication-protocol.md](docs/communication-protocol.md) | Agent 通信协议规范 |
| [docs/resource-management.md](docs/resource-management.md) | 资源管理规范 |
| [docs/debugging-guide.md](docs/debugging-guide.md) | 调试与排错指南 |
| [docs/domain-knowledge.md](docs/domain-knowledge.md) | 领域知识预加载规范（Deepin 等） |

---

## 🐧 领域知识预加载

> **注册表 + 命中时拉取：preset 只维护「触发词 → 仓库地址」映射，skills 内容以仓库实际内容为准。**

### 规则

1. **领域判断**：任务命中触发词（如 `deepin`/`dde`/`dtk`）→ 确定 domain
2. **先拉取**：从注册项的 `repo_url` clone 或 pull 到 `cache_dir`，验证最新提交
3. **再阅读**：读仓库 README 索引，按任务选择匹配的 SKILL.md
4. **后执行**：将要点写入子 agent prompt，再分发任务

### 当前注册项

| id | 领域 | 仓库 |
|----|------|------|
| `deepin` | Deepin/UOS/DDE 开发 | [linuxdeepin/deepin-skills](https://github.com/linuxdeepin/deepin-skills) |

新增领域 = 在 `workflow-preset.json` 的 `domain_knowledge_preload.domains` 加一条注册项，无需改动其他文档。

详见 [docs/domain-knowledge.md](docs/domain-knowledge.md)

---

## 📊 质量标准摘要

详见 `docs/quality-standards.md`

| 维度 | 标准 |
|------|------|
| 命名 | camelCase(JS) / snake_case(Python)，函数动词开头 |
| 注释 | 解释 Why，不解释 What；禁止注释掉的代码 |
| 错误处理 | 所有错误路径必须处理，禁止静默吞错 |
| 函数日志 | 开发验证阶段输出所有函数调用日志，敏感数据脱敏 |
| 依赖 | 最小化，优先选择维护良好的包 |
| 测试 | 覆盖率 ≥ 80% |

---

## 📜 License

MIT
