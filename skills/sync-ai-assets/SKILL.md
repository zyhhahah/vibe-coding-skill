---
name: sync-ai-assets
description: Push local AI assets (skills, settings, memory) to GitHub. Upload direction only — local changes → cloud. Use when the user asks to sync, publish, push, or upload AI assets.
---

# Sync AI Assets

## Direction

**Upload only** — push local changes to the cloud. For downloading/initializing from the cloud, use `/sync-claude-config`.

## Where Assets Live

The canonical location is `~/.claude/`, which must be a git repo connected to:

```
https://github.com/zyhhahah/vibe-coding-skill.git
```

Branch: `main`.

## Prerequisites

`~/.claude/` MUST already be a git repo. If it's not, tell the user to run `/sync-claude-config` first to clone from the cloud.

Do NOT `git init` — that creates a fresh empty repo and loses the connection to existing cloud assets.

## Workflow

### 1. Check prerequisites

```bash
git -C ~/.claude status 2>&1
```

If this fails (not a git repo), stop and instruct: "Run /sync-claude-config first to initialize from the cloud."

### 2. Check connectivity

```bash
git -C ~/.claude ls-remote --heads origin 2>&1
```

If this fails with "Couldn't connect" or similar, warn the user and offer to:
- Commit locally now, push later when network is available
- Skip entirely

### 3. Inspect changes

```bash
git -C ~/.claude status --short
git -C ~/.claude diff --stat
git -C ~/.claude log --oneline -3
```

### 4. Preview

Summarize what changed:
- Modified files
- New files
- Deleted files
- Any risky files (see Safety)

### 5. Stage

Stage only AI asset files:

```bash
git -C ~/.claude add skills/ settings.json memory/ .gitignore
```

Never use `git add -A` or `git add .` unless explicitly asked.

### 6. Commit

```bash
git -C ~/.claude commit -m "Sync AI assets: <summary>"
```

### 7. Push

```bash
git -C ~/.claude push origin main
```

Report: commit hash and whether push succeeded.

If push fails (network error), tell the user the commit is saved locally and can be pushed later with `git -C ~/.claude push origin main`.

## Safety

- Never force push
- Never stage: `.credentials.json`, `.env`, files with `token`/`secret`/`key`/`password` in name
- Always preview before committing
- Never `git init`
