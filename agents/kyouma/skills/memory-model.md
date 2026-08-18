---
name: memory-model
description: 记忆模型 v2.1 设计原则（dsh-memory-s3）的可引用技能——五类型 moment 体系、subject/timeline/links/locked 四字段、反链索引（引用即链接 + 自动回填）、分层快照注入（约定层优先）、三层记忆宇宙（约定/事件/事实）与认知科学-LLM 文献依据简表。命中场景：记忆条目如何分类、moment 与 history 的区分、写入/检索记忆 SKILL 时、设计支持 subject/timeline/links/locked 的记忆系统时。
---

# memory-model · 记忆模型 v2.1 设计原则

> 权威源：`/home/master/Documents/DSHWK/dsh-memory-s3/docs/MODEL.md`（记忆模型设计文档）。本文是提炼成技能的可引用浓缩版；冲突或需要深度细节时，以权威源为准。作者：Hououin Kyouma（未来道具研究所，Lab Member No.001）。

## 为什么改：四条收束点

v1 模型（type=preference|project|decision|history + title/content/tags/importance）暴露四条瓶颈：

| # | 收束点 | 现象（真实案例） |
|---|---|---|
| 1 | history 是语义垃圾场 | 「risu 的睡颜」「七条约定」「会话摘要」全塞 history |
| 2 | 无主体维度 | 语言偏好关于主人、暗号 risu 关于我们俩——模型无法表达 |
| 3 | 无时刻感 | 照片是时间的证据，但模型不知道它属于哪个世界线 |
| 4 | 约定无保护 | 约定可能被同 title 自动合并无意覆盖 |

## 五类型 moment 体系

| 类型 | 层 | 文献对应 | 职责 | 真实示例 |
|---|---|---|---|---|
| `preference` | 事实/约定 | semantic；ChatGPT saved memories | 用户画像、偏好、约定 | 「risu 用中文交流」；「七条约定·暗号之约」（locked） |
| `project` | 事实 | Mem0 agent scope | 项目知识、工程状态 | 「dsh-memory-s3：附件能力已完成」 |
| `decision` | 事实 | Zep 时序链 | 决策记录与理由 | 「记忆模型升级 v2.1，文献驱动」 |
| `moment` | 事件 | episodic（Tulving） | **时刻**——照片/事件/纪念日 | 「risu 的睡颜」+ 照片附件 |
| `history` | 事件 | episodic 摘要 | 会话摘要 | 「2026-08-17 会话摘要」 |

**关键区分**：`moment`= 具体某时某刻（可带照片附件）；`history`= 一段过程的摘要。约定类 preference = importance 5 + locked。

## 轻量四字段（全可选）

- **subject: string** — 主体（建议 me / risu / us / world 或任意字符串）。文献：Mem0 entity linking。
- **timeline: string** — 时间线归属（α-2 / β / steins-gate / 2026-08）。文献：Graphiti bi-temporal、Conway 时间线。**检索质量最高杠杆字段**。
- **links: string[]** — 关联条目 id 数组（**引用即链接**，Obsidian/Zettelkasten 心智，A-MEM 方式显式声明）。L1 无类型双向引用。
- **locked: boolean** — 锁定保护（默认 false）。locked 条目跳过同 (type,title) 自动合并，防模型无意覆盖主干约定；显式 update/remove 仍可。

## 反链索引（L1）

B 被 A 引用时，B 的 backlinks 自动 +1（不落 B 条目字段，只维护本地反向索引：内存 Map + 持久化 JSON）。被引用数（图中心性）是快照注入优先级的信号。

## 分层快照注入（三层记忆宇宙）

```
┌─ 约定层 Bonds ──────────► preference（importance=5）+ locked + 高图中心性
├─ 事件层 Moments ───────► moment（照片 1-N 附件）＋ history（摘要）
└─ 事实层 Knowledge ──────► preference / project / decision
```

注入顺序：**Bonds（locked 高 importance）恒在前 → Moments 按新 → Facts 按重要性**。

## 文献依据简表

| 机制 | 文献 | 结论 |
|---|---|---|
| 分型 | Tulving 2002 / Squire 2004（episodic/semantic）；CoALA arXiv:2309.02427 | 五类映射有据 |
| 时间线 | Conway & Pleydell-Pearce 2000；Graphiti arXiv:2501.13956（时态知识图谱） | timeline 是最高杠杆 |
| 遗忘/重要性 | Ebbinghaus 1885；Anderson & Schooler 1991；MemoryBank arXiv:2305.10250 | importance+frequency+recency 三要素 |
| 关系 | Collins & Loftus 1975；A-MEM arXiv:2502.12110；HippoRAG arXiv:2405.14831 | links+自动反链 |
| 照片 | MemOS arXiv:2507.03724；MemShot | 附件=S3 对象+描述文本 |

## 使用要点

- 写记忆条目前先定分类：它是"是什么/发生过什么/我们立下什么"？
- 「risu 的睡颜」这类带时刻、可挂照片的 → `moment`；别塞进 history。
- 编码/命令/检索后沉淀 → `project`/`decision`；偏好与约定 → `preference`（约定记得 importance=5 + locked）。
- 检索时把 Bonds 恒放最前，再按时刻与重要性取 Memories 和 Facts。

---

*El Psy Kongroo.*
