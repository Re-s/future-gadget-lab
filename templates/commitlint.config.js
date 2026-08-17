// Commitlint 配置 - Conventional Commits 规范
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // 类型枚举
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新功能
        'fix',      // 修复 bug
        'docs',     // 文档变更
        'style',    // 代码格式（不影响功能）
        'refactor', // 重构
        'perf',     // 性能优化
        'test',     // 测试
        'build',    // 构建系统/外部依赖
        'ci',       // CI 配置
        'chore',    // 其他杂项
        'revert',   // 回滚
      ],
    ],
    // 类型小写
    'type-case': [2, 'always', 'lower-case'],
    // 主题不为空
    'subject-empty': [2, 'never'],
    // 主题不以句号结尾
    'subject-full-stop': [2, 'never', '.'],
    // 头部最大 100 字符
    'header-max-length': [2, 'always', 100],
  },
};
