# {PROJECT_NAME}

> {ONE_LINE_DESCRIPTION}

## 📋 项目概述

{DETAILED_DESCRIPTION}

## ✨ 特性

- {FEATURE_1}
- {FEATURE_2}
- {FEATURE_3}

## 🚀 快速开始

### 前置要求

- Node.js >= 18
- pnpm >= 8

### 安装

```bash
# 克隆项目
git clone {REPO_URL}
cd {PROJECT_NAME}

# 安装依赖
pnpm install
```

### 开发

```bash
# 启动开发服务器
pnpm dev

# 运行测试
pnpm test

# 构建生产版本
pnpm build
```

## 📁 项目结构

```
{PROJECT_NAME}/
├── src/
│   ├── core/          # 核心逻辑
│   ├── utils/         # 工具函数
│   └── index.ts       # 入口文件
├── tests/
│   ├── unit/          # 单元测试
│   └── integration/   # 集成测试
├── docs/              # 文档
├── scripts/           # 脚本
├── .github/workflows/ # CI/CD
├── .editorconfig      # 编辑器配置
├── .prettierrc.json   # 格式化配置
├── eslint.config.js   # Lint 配置
├── tsconfig.json      # TypeScript 配置
├── package.json
└── README.md
```

## 🛠️ 开发规范

### 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试
- `chore`: 其他杂项

示例：
```
feat: 添加用户认证模块
fix: 修复登录超时问题
docs: 更新 API 文档
```

### 分支策略

- `main`: 稳定版本
- `develop`: 开发分支
- `feature/*`: 功能分支
- `fix/*`: 修复分支

## 📄 License

[MIT](LICENSE)
