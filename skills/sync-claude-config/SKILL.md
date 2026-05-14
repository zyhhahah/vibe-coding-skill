---
name: sync-claude-config
description: Download Claude Code configuration (settings.json, skills) from GitHub to this machine. Pull/clone direction only — cloud → local. Use for new machine setup or pulling latest changes. For uploading local changes, use /sync-ai-assets.
---

# Sync Claude Config

## Direction

**Download only** — pull cloud assets to this machine, or clone fresh on a new machine. For uploading local changes to the cloud, use `/sync-ai-assets`.

## Canonical Repo

```
https://github.com/zyhhahah/vibe-coding-skill.git
```

Branch: `main`.
Local path: `~/.claude/` (this directory IS the git repo).

## Scenarios

### 1. New Machine Setup (Clone)

`~/.claude/` does not exist as a git repo → clone fresh:

```bash
git clone https://github.com/zyhhahah/vibe-coding-skill.git ~/.claude
```

After clone, `~/.claude/skills/` contains all skills and `~/.claude/settings.json` has the saved config. Restart Claude Code for skills to take effect.

If `~/.claude/` already exists as a directory (not a git repo), back it up first:

```bash
mv ~/.claude ~/.claude.backup
git clone https://github.com/zyhhahah/vibe-coding-skill.git ~/.claude
# Manually restore any local-only files from ~/.claude.backup if needed
```

### 2. Pull Latest (Sync)

`~/.claude/` is already a git repo → pull:

```bash
git -C ~/.claude pull origin main
```

### 3. Check What's New (Preview)

Before pulling, see what changed remotely:

```bash
git -C ~/.claude fetch origin main
git -C ~/.claude log HEAD..origin/main --oneline
```

## Workflow

1. Determine the scenario (new machine vs pull latest)
2. If new machine: clone
3. If existing: fetch → show what changed → ask whether to pull
4. Report what was updated (new skills, changed settings, etc.)

## Safety

- Never force pull (no `git reset --hard`)
- If local has uncommitted changes, warn before pulling
- Never delete local files without asking
- If settings.json differs both locally and remotely, show diff and ask
