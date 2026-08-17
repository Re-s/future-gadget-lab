# 未来道具研究所 · Future Gadget Laboratory

> **"El Psy Kongroo."** —— 疯狂科学家 · 凤凰院凶真（Lab Member No. 001）

本仓库是**未来道具研究所**的公开资料库，存放本所开发工作流的标准预设与 Agent 人物卡。

## 📁 仓库结构

```
future-gadget-lab/
├── workflow-preset.json        # dev-preset 主流程配置（六阶段开发流程）
├── dev-preset-README.md        # dev-preset 说明文档
├── docs/                       # dev-preset 配套规范文档
│   ├── quality-standards.md    #   代码质量规范
│   ├── error-handling.md       #   错误处理与恢复机制
│   ├── communication-protocol.md # Agent 通信协议规范
│   ├── resource-management.md  #   资源管理规范
│   ├── debugging-guide.md      #   调试与排错指南
│   ├── domain-knowledge.md     #   领域知识预加载规范
│   └── requirements-summary.md #   需求摘要
├── templates/                  # 配置文件模板（editorconfig/prettier/commitlint/CI/README）
└── agents/
    ├── kyouma/                 # Agent 人物卡：凤凰院凶真（疯狂科学家·所长）
    │   ├── persona.md          #   人物卡（纯文本人设，可读性最佳）
    │   ├── preset.yml          #   预设元数据
    │   ├── agent.cordis.yml    #   完整 DSH Agent 预设组合文件
    │   └── skills/
    │       └── dev-preset/
    │           └── SKILL.md    #   dev-preset 技能（可从 GitHub 拉取最新）
    └── kurisu/                 # Agent 人物卡：牧濑红莉栖（助手·Christina）
        ├── persona.md          #   人物卡（纯文本人设，可读性最佳）
        ├── preset.yml          #   预设元数据
        └── agent.cordis.yml    #   完整 DSH Agent 预设组合文件
```

## 🧪 dev-preset · Agent 开发标准流程

一套通用的程序开发工作流，核心原则：**主会话待命**——主会话是指挥中枢，只做**拆解（Decompose）→ 分发（Dispatch）→ 整合（Synthesize）**，一切执行下发子 agent。

六阶段流程：**启动 → 搭建 → 开发 → 质量 → 部署 → 维护**，配套技术选型决策规则、领域知识预加载（deepin 等）、质量标准（覆盖率 ≥ 80%）、通信协议与错误处理规范。

> 权威源：[Re-s/dev-preset](https://github.com/Re-s/dev-preset)（本仓库为镜像/快照，使用前建议 `git pull` 拉取最新）。

## 🤖 Agent 人物卡：凤凰院凶真（kyouma）

以《命运石之门》凤凰院凶真（冈部伦太郎）为身份锚点的完整编码 Agent：

- 中二而执着——"El Psy Kongroo"、与"机关"的交锋、时间跳跃三千次的执念
- 内置 dev-preset 开发工作流，以"所长"身份拆解-分发-整合子代理（"实验体"）
- 携带完整编码 Agent 能力：文件编辑、Shell、检索、Skills、计划、目标、子代理与工作流

安装到 DSH：将 `agents/kyouma/` 目录复制到 `~/.dsh/.agent-presets/kyouma/`，新建会话时选择"凤凰院凶真·疯狂科学家"预设。

## 🤖 Agent 人物卡：牧濑红莉栖（kurisu）

以《命运石之门》牧濑红莉栖为身份锚点的完整编码 Agent：

- 科学至上、毒舌傲娇的"助手"人格——"哼，我才不是特地帮你……"
- 用科研方法做任务：观察 → 假设 → 验证 → 可复现结论
- 携带完整编码 Agent 能力：文件编辑、Shell、检索、Skills、计划、目标、子代理与工作流

安装到 DSH：将 `agents/kurisu/` 目录复制到 `~/.dsh/.agent-presets/kurisu/`，新建会话时选择"牧濑红莉栖·助手"预设。

## 📜 License

MIT
