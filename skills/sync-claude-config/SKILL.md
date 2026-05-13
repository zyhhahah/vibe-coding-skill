---
name: sync-claude-config
description: Sync Claude Code configuration (settings.json, installed skills) between this machine and your GitHub repository. Use when the user asks to sync Claude config, push settings to GitHub, pull skills from the cloud, set up Claude on a new machine, or migrate Claude configuration.
---

# Sync Claude Config

## Use This Skill When

- The user says "sync my Claude config", "push my settings", "pull skills from GitHub".
- The user wants to set up Claude Code on a new machine with their existing skills.
- The user has changed settings.json or installed/removed skills and wants to sync.

## New Machine Bootstrap

On a fresh machine with no skills installed, use the bootstrap script at the repo root:

```powershell
git clone https://github.com/zyhhahah/vibe-coding-skill.git
cd vibe-coding-skill
.\setup.ps1
```

To also restore your saved settings.json:

```powershell
.\setup.ps1 -RestoreSettings
```

After bootstrap, all skills (including this one) are available. Use `sync-claude-config -Pull` for ongoing updates.

## Script Location

All ongoing operations delegate to the supporting script:

```
$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1
```

The script auto-discovers the repo path by following its own symlink. If you cloned to a custom location, pass `-RepoPath`.

## Workflows

### Setup (re-link skills from an existing repo)

Creates symlinks for all skills found in the repo. Use this when you already have the repo cloned but need to re-link skills.

```powershell
& "$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1" -Setup
```

### Push (local config to cloud)

Copies `.claude/settings.json` into the repo, commits, and pushes to GitHub.

Preview first:

```powershell
& "$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1" -Push -DryRun
```

Full push:

```powershell
& "$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1" -Push
```

With a custom commit message:

```powershell
& "$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1" -Push -Message "Sync Claude config: updated model preference"
```

### Pull (cloud config to local)

Pulls the latest from GitHub and creates symlinks for any new skills.

```powershell
& "$env:USERPROFILE\vibe-coding-skill\skills\sync-claude-config\scripts\sync-config.ps1" -Pull
```

## Default Workflow

### 1. Determine the user's intent

Ask clarifying questions if the user's request is ambiguous:

- Are they setting up a new machine? → Setup
- Do they want to upload local changes? → Push
- Do they want to download remote changes? → Pull

### 2. Run preview first

Always run with `-DryRun` first so the user can see what will happen before any changes are made.

### 3. Confirm and execute

After preview, confirm with the user and run the real command.

### 4. Report the outcome

- For Push: show the commit hash and confirm push succeeded.
- For Pull: list any new skills that were linked.
- For Setup: list all skills that were set up.

## Safety Rules

- Never force push.
- Never change git config.
- Never skip hooks unless the user explicitly requests it.
- Do not push settings.json if it contains API keys or tokens (the script checks for this).
- Always preview before making changes.
- settings.json is copied as a snapshot — the repo version does not overwrite local settings unless the user explicitly confirms.

## Quick Reference

| Goal | Command |
|------|---------|
| Preview push | `sync-config.ps1 -Push -DryRun` |
| Push settings | `sync-config.ps1 -Push` |
| Preview pull | `sync-config.ps1 -Pull -DryRun` |
| Pull skills | `sync-config.ps1 -Pull` |
| Setup new machine | `sync-config.ps1 -Setup` |
