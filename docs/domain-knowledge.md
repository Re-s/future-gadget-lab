# 领域知识预加载规范

> 注册表 + 命中时拉取：preset 只维护「触发词 → 仓库地址」的映射，skills 内容以仓库实际内容为准。

---

## 📋 目录

1. [核心规则](#-核心规则)
2. [工作机制](#-工作机制)
3. [注册表格式](#-注册表格式)
4. [当前注册项](#-当前注册项)
5. [新增领域](#-新增领域)

---

## 🎯 核心规则

> **任何阶段开始之前，先判断项目是否命中领域触发词；命中则必须先拉取最新 skills 仓库并阅读，再执行后续步骤。**

### 设计原则

1. **单一数据源**：skills 明细（有哪些 skill、适用范围、版本）一律以仓库内 README/SKILL.md 为准，preset 不复制、不硬编码
2. **按需拉取**：命中任务时才下载/更新，未命中不占用任何资源
3. **注册即扩展**：新增领域只需在注册表加一条映射，无需改动其他文档

---

## ⚙️ 工作机制

```
用户提出开发任务
    ↓
主会话拆解任务
    ↓
【匹配触发词】命中注册表中的 domain？
    ├─ 未命中 → 按通用流程执行
    └─ 命中 ↓
        1. cache_dir 不存在 → git clone repo_url
           cache_dir 已存在 → git fetch + git pull
        2. git log -1 验证最新提交
           （失败 → 告知用户缓存日期，由用户决定是否继续）
        3. 读取仓库索引（README / skills 目录）
        4. 按任务选择匹配的 SKILL.md 阅读
        5. 将要点写入子 agent prompt（自包含原则）
        6. 分发子 agent 执行任务
```

### 关键命令

```bash
# 拉取/更新（以注册项的 repo_url 和 cache_dir 为准）
git clone <repo_url> <cache_dir>        # 首次
git -C <cache_dir> fetch origin
git -C <cache_dir> pull                 # 更新

# 验证时效性
git -C <cache_dir> log -1 --format='%h %ci %s'
```

---

## 📐 注册表格式

注册表位于 `workflow-preset.json` 的 `domain_knowledge_preload.domains`：

```json
{
  "id": "domain-id",
  "name": "领域名称",
  "triggers": ["触发词1", "触发词2"],
  "repo_url": "https://github.com/org/skills-repo",
  "cache_dir": "/path/to/cache/dir",
  "note": "一句话备注（如适用版本）"
}
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `id` | ✅ | 领域唯一标识 |
| `name` | ✅ | 领域可读名称 |
| `triggers` | ✅ | 触发词列表，任务描述中命中任一即触发 |
| `repo_url` | ✅ | skills 仓库地址（git 可克隆） |
| `cache_dir` | ✅ | 本地缓存目录 |
| `note` | ⬜ | 备注（适用版本、特殊说明等） |

**注意**：注册项中**不包含** skill 清单——那是仓库自己的 README 的职责。

---

## 📚 当前注册项

| id | 领域 | 仓库 | 备注 |
|----|------|------|------|
| `deepin` | Deepin/UOS/DDE 开发 | [linuxdeepin/deepin-skills](https://github.com/linuxdeepin/deepin-skills) | 适用 deepin/UOS v25；skill 清单见仓库 README |

**触发词**（deepin）：`deepin`、`uos`、`dde`、`dtk`、`dde-shell`、`dde-control-center`、`dde-tray`、`dock`、`launchpad`、`org.deepin`、`DTK Widget`、`DTK QML`

> 有哪些可用 skill、各自适用什么场景——拉取仓库后读它的 README，那里是唯一权威来源。

---

## ➕ 新增领域

只需两步：

1. 在 `workflow-preset.json` 的 `domain_knowledge_preload.domains` 数组追加一条注册项
2. （可选）在本文档「当前注册项」表格加一行索引

**收录标准**：

- [ ] 官方维护或社区公认权威
- [ ] 仓库内有结构化索引（README 列出 skill 清单）
- [ ] 与实际开发场景直接相关
- [ ] 触发词不与其他领域冲突

**不要做的事**：

- ❌ 把仓库里的 skill 明细复制进 preset 或本文档
- ❌ 为某个领域的 skill 写本地化的用法说明（写在仓库上游，而非这里）
