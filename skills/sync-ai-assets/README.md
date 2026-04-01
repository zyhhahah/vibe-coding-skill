# sync-ai-assets

用于把 AI 资产仓库里的变更快速同步到 GitHub。

## 它解决什么问题

- 不想每次手敲整套 `git add` / `git commit` / `git push`
- 想先预览这次会同步哪些资产
- 想在 Cursor 对话里直接说一句话完成同步

## 它依赖什么

- 仓库根目录有 `sync-assets.cmd`
- 仓库里有 `tools/sync-assets.ps1`
- 资产文件位于 `skills/`、`prompts/`、`playbooks/`、`templates/`、`references/` 等目录

## 典型用法

终端预览：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1" -DryRun
```

终端直接同步：

```powershell
.\sync-assets.cmd
```

带自定义提交说明同步：

```powershell
.\sync-assets.cmd -Message "Sync AI assets: skills, tooling"
```

## 在对话里怎么触发

可以直接说：

- 同步我的 AI 资产
- 把刚做好的 skill 推到 GitHub
- 先预览这次会同步哪些资产
- 用一个合适的提交说明发布这些模板和提示词
