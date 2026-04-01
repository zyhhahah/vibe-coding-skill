# vibe-coding-skill

我在使用 AI 编程过程中的可复用资产仓库。

这个仓库不只放 `skills`，也会持续沉淀各种可重复使用的 AI 资产，比如提示词、工作流、模板、参考资料和最佳实践。

## 仓库目标

- 把零散、临时、依赖上下文的 AI 经验，整理成可复用资产
- 让资产既适合人阅读，也适合被 AI 直接消费
- 用稳定的目录结构避免后续越积越乱

## 目录规划

```text
.
├── skills/         # Cursor / Codex / Agent Skills
├── prompts/        # 可单独复用的提示词
├── playbooks/      # 一整套工作流、方法论、操作步骤
├── templates/      # 可填空复用的模板
├── references/     # 稳定参考资料、术语、清单、约束
└── tools/          # 自动化脚本与发布辅助工具
```

### `skills/`

存放可被编辑器或 agent 自动发现和调用的技能。

建议结构：

```text
skills/
└── skill-name/
    ├── SKILL.md
    ├── README.md        # 可选，人类说明
    ├── examples.md      # 可选，示例
    └── reference.md     # 可选，详细参考
```

适合放：

- Cursor Skill
- Codex Skill
- 任何需要固定触发条件和执行规范的 agent 能力

### `prompts/`

存放可独立使用的提示词，不要求被某个系统自动发现。

建议按主题或场景再分一层，比如：

```text
prompts/
├── coding/
├── writing/
├── product/
└── research/
```

每个 prompt 文件建议写清楚：

- 用途
- 适用场景
- 输入项
- 输出要求
- 示例

### `playbooks/`

存放“不是一句 prompt 能解决”的完整流程。

适合放：

- 长对话交接流程
- Bug 排查流程
- AI 代码评审流程
- 从需求到 PR 的标准操作

### `templates/`

存放结构化模板，强调“填空即用”。

适合放：

- 上下文交接模板
- PRD 模板
- 代码评审模板
- issue 描述模板

### `references/`

存放相对稳定的资料，而不是一次性对话产物。

适合放：

- 命名规范
- 常见约束
- 术语表
- 风格指南
- 常见坑清单

### `tools/`

存放帮助你维护、发布和同步 AI 资产的自动化工具。

适合放：

- 一键同步脚本
- 资产检查脚本
- 批量整理脚本
- 发布辅助工具

## 收录原则

- 优先收录“跨项目可复用”的内容
- 一个资产只解决一类问题，避免大而杂
- 尽量让文件名能直接表达用途
- 技能给 AI 读，说明给人读，需要时可以同时存在

## 命名建议

- 目录名和技能名优先使用短横线风格，例如 `long-context-handoff`
- 同一类资产统一命名方式，不混用拼音、空格和缩写
- 优先写清“做什么”，再体现“适用于什么场景”

## 当前已收录

- `skills/long-context-handoff`
  - 解决长对话变慢、跑偏、上下文衰减的问题
  - 提供交接摘要模板、新对话启动模板、分阶段压缩方法和滚动摘要方法
- `skills/sync-ai-assets`
  - 用于检查仓库变更、草拟提交说明并触发同步脚本
- `tools/sync-assets.ps1`
  - Windows 友好的 AI 资产一键同步脚本
- `sync-assets.cmd`
  - 仓库根目录下的快速入口

## 如何同步资产

这个仓库默认提供两种同步方式：终端脚本和对话式 skill。

### 方式一：终端一键同步

在仓库根目录执行：

```powershell
.\sync-assets.cmd
```

这会默认：

- 扫描仓库里全部未提交的变更
- 显示将要同步的文件
- 自动生成提交说明（如果你没传）
- 执行 `git add --all`、`git commit`、`git push`

如果你想先预览，不真正提交：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1" -DryRun
```

如果你想自定义提交说明：

```powershell
.\sync-assets.cmd -Message "Sync AI assets: skills, tooling"
```

### 方式二：在 Cursor 对话里触发

仓库里提供了 `skills/sync-ai-assets` 这份技能资产，用来规范“检查变更 -> 总结范围 -> 生成提交说明 -> 触发同步”的流程。

常见说法：

- 同步我的 AI 资产
- 把刚做好的 skill 推到 GitHub
- 先预览这次会同步哪些文件
- 给这次资产更新生成一个合适的提交说明并发布

### 常用建议

- 如果只是想确认范围，先用 `-DryRun`
- 如果仓库里有与你这次发布无关的改动，先清理或拆分
- 如果有敏感文件，不要直接同步

## 推荐的后续补充方向

- `prompts/coding/`
  - 代码重构提示词
  - bug 定位提示词
  - PR 评审提示词
- `playbooks/`
  - 从需求到交付的 AI 协作流程
  - 多轮对话失真后的恢复流程
- `templates/`
  - 周报模板
  - 需求澄清模板
  - 技术方案模板
