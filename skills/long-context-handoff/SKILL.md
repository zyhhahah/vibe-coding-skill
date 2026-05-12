---
name: long-context-handoff
description: Summarizes long GPT or ChatGPT conversations into compact handoff briefs and fresh-chat kickoff prompts. Use when the user mentions long conversations, context degradation, slow responses, summarizing history, preserving state across chats, 卡顿, 总结上下文, 新开对话, or continuing work without losing important context.
---

# Long Context Handoff

## Use This Skill When

- A conversation has become slow, noisy, or lower quality because context is too long.
- The user wants to start a fresh chat without losing important state.

Respond in the user's language unless they ask otherwise.

## Core Principle

Do not carry over the full transcript. Carry over only the state required for success in the next chat.

Preserve three layers:
1. **Long-term context** — identity, project background, fixed preferences, definitions, stable constraints.
2. **Phase context** — current goal, decisions made, attempts, results, blockers.
3. **Current request** — what the next model should do now, required output format, hard boundaries.

Always separate: confirmed facts, assumptions, and preferences.

## Default Workflow

1. **Identify the mode:** Advice (teach the user how), Handoff (compress current conversation), Kickoff (build a fresh-chat starter from a summary), Rolling (repeatable method every 20-40 turns). Default to Advice if unclear.
2. **Compress for continuity, not completeness.** Remove greetings, repetition, dead ends. Keep only what changes the next model's behavior. Compress in this order: Core goal → Background → Confirmed facts → Decisions and why → Attempts and outcomes → Open issues → Constraints → Key terms → Next actions → Kickoff prompt.
3. **If chaotic, compress in stages:** Summarize early phase → middle phase → current phase → merge into one handoff brief.
4. **Next chat starts with alignment, not execution.** The next model must: restate understanding → surface missing info → flag conflicts → propose best path → wait for confirmation.

Reusable prompt blocks for each mode are in [prompt-blocks.md](prompt-blocks.md).

## Response Rules

- Prefer concise structure over long explanation.
- Do not dump the whole transcript back.
- If the user asks "how to phrase it," give a short explanation plus a ready-to-paste prompt.
- If the user asks for the actual summary, produce it directly.

## Common Failure Modes

- Asking the model to "summarize everything" with no schema.
- Copying the full transcript into the new chat.
- Mixing facts, assumptions, and preferences together.
- Letting the new chat begin execution before alignment.
- Preserving wording instead of preserving state.

## Quick Checklist

- [ ] Long-term context captured
- [ ] Phase context captured
- [ ] Current request captured
- [ ] Facts separated from guesses
- [ ] Constraints and preferences explicit
- [ ] Open issues visible
- [ ] Next actions clear
