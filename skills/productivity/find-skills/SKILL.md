---
name: find-skills
description: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. Use when the user is looking for functionality that might exist as an installable skill.
---

# Find Skills

Discover and install skills from the open agent skills ecosystem via the Skills CLI (`npx skills`).

## When to Use

Use when the user:
- Asks "how do I do X" where X might have an existing skill
- Says "find a skill for X" or "is there a skill for X"
- Wants to extend agent capabilities
- Mentions they wish they had help with a specific domain (design, testing, deployment, etc.)

## Skills CLI Quick Reference

- `npx skills find [query]` — Search for skills
- `npx skills add <package>` — Install a skill
- `npx skills check` — Check for updates
- `npx skills update` — Update all installed skills
- Browse: https://skills.sh/

## Workflow

### Step 1: Identify the Need

Extract: (1) the domain, (2) the specific task, (3) whether it's common enough that a skill likely exists.

### Step 2: Check the Leaderboard

Check https://skills.sh/ before running a CLI search. Top skills come from:
- `vercel-labs/agent-skills` — React, Next.js, web design
- `anthropics/skills` — Frontend design, document processing

### Step 3: Search

```bash
npx skills find [query]
```

Use specific keywords. Try alternative terms if the first search misses.

### Step 4: Verify Quality

Always verify before recommending:
1. **Install count** — Prefer 1K+ installs. Be cautious under 100.
2. **Source reputation** — Prefer official sources (`vercel-labs`, `anthropics`, `microsoft`).
3. **GitHub stars** — <100 stars = treat with skepticism.

### Step 5: Present Options

Include: skill name + purpose, install count + source, install command, skills.sh link.

Example:
```
I found a skill! "react-best-practices" provides React/Next.js
performance optimization from Vercel Engineering. (185K installs)

To install:
npx skills add vercel-labs/agent-skills@react-best-practices

Learn more: https://skills.sh/vercel-labs/agent-skills/react-best-practices
```

### Step 6: Offer to Install

```bash
npx skills add <owner/repo@skill> -g -y
```

`-g` = global (user-level), `-y` = skip confirmations.

## When No Skills Are Found

1. Acknowledge no existing skill was found
2. Offer to help with the task directly
3. Suggest creating their own skill: `npx skills init my-skill`

See [REFERENCE.md](REFERENCE.md) for common skill categories and search tips.
