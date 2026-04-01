---
name: sync-ai-assets
description: Publish reusable AI assets from the repository to GitHub by reviewing git changes, drafting a commit message, and running the local sync script. Use when the user asks to sync, publish, push, upload, or update AI assets such as skills, prompts, playbooks, templates, or references.
---

# Sync AI Assets

## Use This Skill When

- The user says "sync my AI assets", "publish this skill", or "push these prompts to GitHub".
- The user has changed files under `skills/`, `prompts/`, `playbooks/`, `templates/`, or `references/`.
- The user wants either a preview of the sync or the full commit-and-push flow.

## Expected Repository Layout

This skill assumes the asset repository contains:

- `tools/sync-assets.ps1`
- `sync-assets.cmd`
- asset folders such as `skills/`, `prompts/`, `playbooks/`, `templates/`, and `references/`

If the sync script is missing, add or restore it before attempting to publish.

## Default Workflow

### 1. Inspect the repository state

Run these checks first:

- `git status --short`
- `git diff -- <relevant paths>`
- `git log --oneline -5`

Summarize:

- what changed
- which asset types were touched
- whether anything looks unrelated to the user's request

### 2. Check for risky files

Stop and warn the user if the pending changes include likely secrets or local-only files, for example:

- `.env`
- credentials files
- tokens
- private exports that should not be published

Also stop if the working tree contains clearly unrelated changes and the user did not ask to sync everything.

### 3. Decide between preview and publish

Use preview mode when the user wants to inspect first:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1" -DryRun
```

Use the full publish flow when the user explicitly asks to sync or push:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1"
```

If the user provided a commit message, pass it through:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools/sync-assets.ps1" -Message "your message here"
```

If the user is already in the repository root on Windows, the wrapper is also valid:

```bat
sync-assets.cmd
```

### 4. Draft a good commit message

If the user did not provide a message, draft one that focuses on why the assets changed.

Prefer concise messages such as:

- `Sync AI assets: skills`
- `Sync AI assets: prompts, templates`
- `Update publishing workflow for reusable AI assets`

### 5. Report the result

After preview or publish, tell the user:

- which files were included
- which command was used
- the commit hash if a commit was created
- whether the push succeeded

## Safety Rules

- Never force push.
- Never change git config.
- Never skip hooks unless the user explicitly requests it.
- Do not publish secrets or credentials.
- If the user asked only for a preview, do not perform the real push.

## Quick Response Pattern

When this skill is applied, follow this sequence:

1. Check repo status.
2. Summarize the pending asset changes.
3. Draft or confirm the commit message.
4. Run `-DryRun` for preview requests or the real sync command for publish requests.
5. Report the outcome clearly.
