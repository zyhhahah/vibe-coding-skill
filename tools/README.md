# tools

这里存放维护和发布 AI 资产仓库用的自动化工具。

## 当前工具

- `sync-assets.ps1`
  - 扫描仓库改动
  - 显示即将同步的文件
  - 自动生成或接受自定义提交说明
  - 执行 `git add --all`、`git commit`、`git push`

## 快速使用

在仓库根目录执行：

```powershell
.\sync-assets.cmd
```

只预览，不真正同步：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1" -DryRun
```
