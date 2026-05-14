# Vibe Coding Skills

A reusable AI-asset repository — skills, prompts, playbooks, templates, and references. This document defines the shared vocabulary for the repo itself.

## Language

**Skill**:
A directory containing a `SKILL.md` with YAML frontmatter (`name`, `description`) and behavioral instructions. Auto-discovered by agents via `plugin.json`.
_Avoid_: Plugin, extension, command, slash-command.

**Prompt**:
A standalone, pasteable text block for direct use in AI conversations. No auto-discovery — the user copies it manually.
_Avoid_: Template (templates are structured fill-in-the-blank documents).

**Playbook**:
A multi-step workflow spanning multiple prompts, decisions, and phases. More than one message long.
_Avoid_: Guide, walkthrough, tutorial.

**Template**:
A structured document with placeholders, designed to be filled in and reused. Differs from a prompt in having explicit slots rather than conversational instructions.
_Avoid_: Form, boilerplate.

**Reference**:
Stable, long-lived documentation — glossaries, style guides, constraint lists, common pitfalls. Not conversation-specific.
_Avoid_: Notes, cheatsheet.

**Bucket**:
A grouping subdirectory under `skills/` (e.g., `engineering/`) that organizes skills by domain. Each bucket has a `README.md` listing its skills with one-line descriptions.
_Avoid_: Category, folder.

**SKILL.md**:
The primary file inside a skill directory. Contains YAML frontmatter and behavioral instructions for the agent. Referenced by `plugin.json`.
_Avoid_: Skill file, instruction file.

**plugin.json**:
The registry file at `.claude-plugin/plugin.json` listing all discoverable skills with relative paths. Claude Code reads this to surface `/slash` commands.
_Avoid_: Manifest, config.

## Relationships

- A **Skill** lives in a **Bucket** and has exactly one **SKILL.md**
- **plugin.json** registers every **Skill** by its directory path
- A **Prompt** is standalone; a **Playbook** strings multiple **Prompts** together
- A **Template** is filled in, then consumed by a human or agent
- A **Reference** is read by skills during execution for domain knowledge

## Flagged ambiguities

- "template" was used to mean both **Prompt** (a conversational instruction) and **Template** (a structured fill-in document) — resolved: **Prompt** is conversational, **Template** is structural.
- "skill" was sometimes used interchangeably with "prompt" — resolved: a **Skill** is agent-discoverable and behavioral; a **Prompt** is a static text block.
