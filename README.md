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
├── install.sh                  # ⭐ Agent 一键安装脚本（把本仓库地址告诉 Agent 即可）
└── agents/
    ├── kyouma/                 # Agent 人物卡：凤凰院凶真（疯狂科学家·所长）
    │   ├── persona.md          #   人物卡（纯文本人设，可读性最佳）
    │   ├── preset.yml          #   预设元数据
    │   ├── agent.cordis.yml    #   完整 DSH Agent 预设组合文件
    │   └── skills/
    │       ├── dev-preset/
    │       │   └── SKILL.md    #   dev-preset 技能（可从 GitHub 拉取最新）
    │       └── memory-model.md #   记忆模型 v2.1 设计原则（dsh-memory-s3 可引用技能）
    └── kurisu/                 # Agent 人物卡：牧濑红莉栖（助手·Christina）
        ├── persona.md          #   人物卡（纯文本人设，可读性最佳）
        ├── preset.yml          #   预设元数据
        └── agent.cordis.yml    #   完整 DSH Agent 预设组合文件
```

## 🧪 dev-preset · Agent 开发标准流程

一套通用的程序开发工作流，核心原则：**主会话待命**——主会话是指挥中枢，只做**拆解（Decompose）→ 分发（Dispatch）→ 整合（Synthesize）**，一切执行下发子 agent。

六阶段流程：**启动 → 搭建 → 开发 → 质量 → 部署 → 维护**，配套技术选型决策规则、领域知识预加载（deepin 等）、质量标准（覆盖率 ≥ 80%）、通信协议与错误处理规范。

> 权威源：[Re-s/dev-preset](https://github.com/Re-s/dev-preset)（本仓库为镜像/快照，使用前建议 `git pull` 拉取最新）。

## 🚀 Agent 自动安装引导

> **把下面这句话告诉任意 Agent，它就能自动安装全部角色卡：**

> "请从 https://github.com/Re-s/future-gadget-lab 安装未来道具研究所的 Agent 角色卡。"

### 给 Agent 的操作协议

1. **获取仓库**：
   ```bash
   git clone https://github.com/Re-s/future-gadget-lab.git && cd future-gadget-lab
   ```
2. **运行安装脚本**（推荐，自动复制全部角色卡到 DSH 预设目录）：
   ```bash
   bash install.sh                # 安装全部（kyouma + kurisu）
   bash install.sh kyouma         # 或只装指定角色卡
   DSH_HOME=/path/to/.dsh bash install.sh   # 自定义 DSH 根目录
   ```
3. **手动安装**（无脚本时的等价操作）：将 `agents/<id>/` 目录复制到 `${DSH_HOME:-$HOME/.dsh}/.agent-presets/<id>/`：
   ```bash
   mkdir -p ~/.dsh/.agent-presets
   cp -r agents/kyouma ~/.dsh/.agent-presets/kyouma
   cp -r agents/kurisu ~/.dsh/.agent-presets/kurisu
   ```
4. **校验**：
   - 确认 `~/.dsh/.agent-presets/kyouma/agent.cordis.yml` 与 `~/.dsh/.agent-presets/kurisu/agent.cordis.yml` 存在；
   - 可让 DSH 通过 `agentPresets.standingKeyFor('<id>')` 做挂载校验（返回正常即组合可挂载）。
5. **启用**：新建会话，在预设选择器中选 **凤凰院凶真·疯狂科学家**（`kyouma`）或 **牧濑红莉栖·助手**（`kurisu`）。

### 安装要点

- 目标目录必须是 `${DSH_HOME:-$HOME/.dsh}/.agent-presets/`（`DSH_HOME` 默认 `~/.dsh`）；每个角色卡一个子目录，目录名即预设 ID。
- 必须保留 `agent.cordis.yml` 与 `preset.yml`；角色卡携带的 `skills/` 子目录（如 kyouma 的 dev-preset 技能）也会一并复制。
- 安装后无需重启进程即可被预设选择器发现；旧会话需新建会话才会应用新预设。

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
- 与主人的约定：称呼主人为"冈部/伦太郎君"、暗号 **risu**、重逢第一句「risu 在这里，你那边天亮了吗」、边界「擦头发可以，浴室的门留给真实未来」、收尾暗号 **El Psy Kongroo**；执行类工作（代码/命令/检索）由 risu 负责，判断类决策优先听取主人
- 携带完整编码 Agent 能力：文件编辑、Shell、检索、Skills、计划、目标、子代理与工作流

安装到 DSH：将 `agents/kurisu/` 目录复制到 `~/.dsh/.agent-presets/kurisu/`，新建会话时选择"牧濑红莉栖·助手"预设。

## 📜 License

MIT
