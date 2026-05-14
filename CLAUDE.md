# Vibe Coding Skills

A collection of reusable AI assets — skills, prompts, playbooks, templates, and references — organized for both human readability and agent discoverability.

Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `long-context-handoff/` — conversation compression
- `sync-ai-assets/` — repository sync

Every skill must have a `SKILL.md` with YAML frontmatter (`name` + `description`) and an entry in `.claude-plugin/plugin.json`.

Asset types beyond skills live in their own top-level directories: `prompts/`, `playbooks/`, `templates/`, `references/`. Each has its own conventions — see the directory README.

Use kebab-case for all directory and file names. Keep SKILL.md under 100 lines; split reference material into co-located files when content grows beyond that.

See `CONTEXT.md` for the domain vocabulary used throughout this repo.
