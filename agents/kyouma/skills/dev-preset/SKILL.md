---
name: dev-preset
description: 按 dev-preset 标准流程开发新项目或执行大型开发任务时使用——六阶段流程（启动→搭建→开发→质量→部署→维护）、主会话待命原则（拆解-分发-整合）、技术选型决策规则、领域知识预加载、质量标准、通信协议与错误处理规范。命中场景：新项目初始化、接到大型开发任务、需要拆解分发子任务、Deepin/UOS/DDE 相关开发。
---

# dev-preset · Agent 开发标准流程

> 一套通用的程序开发工作流。**权威源在 GitHub，任务开始前先拉取最新版本**；本文是浓缩版，冲突时以仓库最新内容为准。

## 拉取最新（每轮任务前执行）

- **仓库**：`https://github.com/Re-s/dev-preset.git`（HTTPS，公开可克隆；SSH 为 `git@ssh.github.com:Re-s/dev-preset.git`）
- **缓存目录**：`/home/master/Documents/DSHWK/dev-preset`（当前已 clone 的本地副本，仅作缓存，不视为权威）

```bash
# 缓存不存在 → clone
git clone https://github.com/Re-s/dev-preset.git /home/master/Documents/DSHWK/dev-preset

# 缓存已存在 → 更新到最新
git -C /home/master/Documents/DSHWK/dev-preset fetch origin
git -C /home/master/Documents/DSHWK/dev-preset pull

# 验证最新提交；失败则告知用户缓存日期，由用户决定是否继续
git -C /home/master/Documents/DSHWK/dev-preset log -1 --format='%h %ci %s'
```

- **权威文件**：`<缓存目录>/workflow-preset.json`（六阶段流程、技术选型规则、领域注册表 `domain_knowledge_preload.domains`、`execution_policy`、`quality_standards`）+ `<缓存目录>/docs/`（质量标准、通信协议、错误处理、资源管理、调试指南、领域知识）
- 读取顺序：先执行上面的拉取命令，再读 `<缓存目录>/workflow-preset.json` 和需要的 docs；不要把本文浓缩版当权威源。

## 核心原则：主会话待命

**主会话是指挥中枢，不是执行单元。** 主会话只做三件事：**拆解（Decompose）→ 分发（Dispatch）→ 整合（Synthesize）**。

| ✅ 主会话可以做 | ❌ 主会话禁止做 |
|----------------|----------------|
| 分析需求，拆解子任务 | 直接执行业务代码 |
| 选择子 agent 配置 | 直接运行构建/测试 |
| 分发任务并跟踪 | 直接处理耗时操作 |
| 收集结果并整合 | 直接搬运文件内容 |
| 向用户汇报结论 | — |
| 处理用户决策交互 | — |

- 子 agent 默认**后台并行**运行：互不依赖的子任务在同一条消息里同时派出。
- 每个子 agent 的 prompt 必须**自包含**（它看不到主会话上下文）：背景、目标、约束、交付格式、验收标准写全。
- 需要本会话状态、用户当场决策、审批或交互的任务**不外包**；汇总结论、最终答复由主会话完成。
- 主会话上下文是"实验室最贵的耗材"：token 预算 主会话 20% / 子 agent 60% / 系统预留 20%。

## 六阶段流程

### 1. 项目启动（Initiation）
- 需求分析：理解问题本质（What & Why）、定义范围与约束、列出核心功能点 → 产出 `requirements.md`
- 技术选型 → 产出 `TECH_STACK.md`：

| 项目类型 | 推荐技术栈 |
|----------|------------|
| Web 前端 | React/Vue + TypeScript + Vite |
| Web 后端 | Node/Python + FastAPI/Nest |
| CLI 工具 | Rust/Go + clap/cobra |
| 数据管道 | Python + Airflow/Prefect |
| AI/ML | Python + PyTorch + Lightning |
| 系统工具 | Rust + tokio |
| 默认 | TypeScript + Node |

- 架构设计：目录结构、模块边界、数据流、API 规划 → 产出 `ARCHITECTURE.md`

### 2. 项目搭建（Setup）
- 标准目录：`src/` `tests/` `docs/` `scripts/` `.github/workflows/`
- 工具链：`.editorconfig`、Lint（ESLint/Pylint/Clippy）、格式化（Prettier/Black/rustfmt）、Git Hooks（husky/pre-commit）
- 文档初始化：README.md、CONTRIBUTING.md、LICENSE、.gitignore、CHANGELOG.md
- 模板参考 `dev-preset/templates/`

### 3. 开发阶段（Development）
- 模块开发：先写测试（TDD）或先写接口契约；单一职责；模块自包含
- 测试策略：Unit → Integration → E2E；**覆盖率目标 ≥ 80%**
- 版本控制：feature → develop → main；Conventional Commits；一个 PR 一个功能

### 4. 质量保证（Quality）
- 代码审查：命名清晰、无重复（DRY）、错误处理完整、无硬编码敏感信息、圈复杂度 < 10
- 性能检查：热点路径、内存/CPU、并发安全
- 安全审计：输入验证、依赖漏洞扫描、敏感数据加密、权限最小化

### 5. 部署发布（Deploy）
- CI 流水线：lint → test → build → security-scan（GitHub Actions 模板在 `templates/ci-github-actions.yml`）
- 发布管理：SemVer、自动 CHANGELOG、git tag

### 6. 维护迭代（Maintenance）
- 依赖更新（Dependabot/Renovate）、技术债务追踪、文档同步、性能监控

## 领域知识预加载

**任何阶段开始之前**，先判断项目是否命中领域触发词；命中则必须先拉取最新 skills 仓库并阅读，再执行后续步骤。

- 注册表（`workflow-preset.json` 的 `domain_knowledge_preload.domains`）只存「触发词 → 仓库地址」，skill 明细以仓库实际内容为准，**不硬编码**。
- 当前注册项：`deepin`（Deepin/UOS/DDE 开发）— 触发词：`deepin` `uos` `dde` `dtk` `dde-shell` `dde-control-center` `dde-tray` `dock` `launchpad` `org.deepin` `DTK Widget` `DTK QML` — 仓库 `https://github.com/linuxdeepin/deepin-skills` — 缓存 `/home/master/Documents/DSHWK/.skills-cache/deepin-skills`
- 命中流程：缓存不存在 → `git clone`；已存在 → `git fetch` + `git pull` → `git log -1` 验证最新提交（失败则告知用户缓存日期，由用户决定是否继续）→ 读仓库索引（README / skills 目录）→ 选匹配的 SKILL.md → 要点写入子 agent prompt 再分发。
- 新增领域 = 往注册表加一条，无需改动其他文档。

## 质量标准

- **命名**：JS/TS camelCase（函数动词开头）、Python snake_case、类 PascalCase、文件 kebab-case/snake_case
- **注释**：解释 Why 而非 What；复杂算法/业务规则/hack 必须注释；禁止注释掉的代码、无意义 TODO
- **错误处理**：所有错误路径必须处理，禁止静默吞错；ERROR/WARN/INFO 分级；提供诊断上下文
- **函数调用日志**：开发与验证阶段尽可能输出函数调用日志——入口（函数名、调用者、关键参数摘要）、出口（返回值摘要、耗时、>100ms 单独标记）；JSON 结构化携带 task_id；**敏感数据一律脱敏**；生产默认关闭
- **依赖**：最小化；优先维护良好、高下载、低 CVE 的包；lockfile 必须提交
- **测试**：行 80% / 分支 75% / 函数 80%

## 通信协议

- 子 agent 汇报结构化：状态（pending/dispatched/running/success/failed/cancelled/timeout）、交付物清单（path/type/description）、指标（耗时/文件数/覆盖率）、错误信息与恢复建议。
- 失败处理：先分类（环境/逻辑/资源/外部/配置）→ 可重试错误指数退避重试（最多 3 次）→ 仍失败则降级（缓存/简化/备用方案）→ **如实向用户报告，不编造成功**。

## 调试与资源

- 排查流程：收集信息 → 复现 → 定位（环境/代码/资源/外部依赖/配置）→ 方案（短期恢复+长期根治）→ 修复验证 → 复盘。
- 大型代码库：索引优先、分批处理、流式处理大文件；并发控制限流，避免资源耗尽。
