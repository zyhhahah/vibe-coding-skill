# skills

这里存放可被 Cursor、Codex 或其他 agent 系统直接发现和复用的技能。

## 目录约定

每个 skill 单独一个目录：

```text
skills/
└── skill-name/
    ├── SKILL.md
    ├── README.md        # 可选
    ├── examples.md      # 可选
    └── reference.md     # 可选
```

## 最低要求

- 必须有 `SKILL.md`
- `SKILL.md` 里要包含清晰的 `name` 和 `description`
- `description` 要同时说明“做什么”和“什么时候用”

## 当前技能

- `long-context-handoff`: 长对话交接与上下文压缩
