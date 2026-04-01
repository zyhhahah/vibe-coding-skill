---
name: long-context-handoff
description: Summarizes long GPT or ChatGPT conversations into compact handoff briefs and fresh-chat kickoff prompts. Use when the user mentions long conversations, context degradation, slow responses, summarizing history, preserving state across chats, 卡顿, 总结上下文, 新开对话, or continuing work without losing important context.
---

# Long Context Handoff

## Use This Skill When

- A conversation has become slow, noisy, or lower quality because the context is too long.
- The user wants to start a fresh chat without losing important state.
- The user asks how to summarize a long GPT conversation effectively.
- The user wants a reusable handoff prompt, kickoff prompt, or rolling summary workflow.

Respond in the user's language unless they ask otherwise.

## Core Principle

Do not carry over the full transcript. Carry over only the state required for success in the next chat.

Preserve exactly three layers of context:

1. `Long-term context`
   - Identity, project background, fixed preferences, definitions, stable constraints.
2. `Phase context`
   - Current goal, decisions made, attempts, results, blockers, dependencies.
3. `Current request`
   - What the next model should do now, required output format, and hard boundaries.

Always separate:

- `Confirmed facts`
- `Assumptions or unverified items`
- `Preferences and constraints`

## Default Workflow

### 1. Identify the deliverable

Pick the closest mode:

- `Advice mode`: The user wants to know how to phrase a good summary prompt.
- `Handoff mode`: The user wants the current long conversation compressed into a reusable brief.
- `Kickoff mode`: The user already has a summary and wants a strong fresh-chat starting prompt.
- `Rolling mode`: The user wants a repeatable method to summarize every 20-40 turns.

If the user is vague, default to `Advice mode` plus ready-to-paste templates.

### 2. Compress for continuity, not completeness

When building a handoff summary:

- Remove greetings, repetition, dead ends, and low-value intermediate chatter.
- Keep only information that changes the next model's behavior or decisions.
- Prefer stable structure over free-form prose.
- Keep the first pass compact unless the user asks for a detailed version.

Use this order:

1. Core goal
2. Background summary
3. Confirmed facts
4. Decisions made and why
5. Attempts and outcomes
6. Open issues
7. Constraints and preferences
8. Important entities or terms
9. Next best actions
10. Fresh-chat kickoff prompt

### 3. If the history is chaotic, compress in stages

Do not ask the model to "summarize everything above" in one shot when the thread is messy.

Instead:

1. Summarize `early phase`
2. Summarize `middle phase`
3. Summarize `current phase`
4. Merge the three summaries into one final handoff brief

If the task is fragile, also add:

- `Do not forget`
- `Rejected options`
- `Non-negotiable constraints`

### 4. Start the next chat with alignment, not execution

The next model should not immediately act on the task. It should first:

1. Restate its understanding
2. Surface missing information
3. Point out conflicts or uncertainty
4. Propose the best path
5. Wait for confirmation when needed

This prevents the common failure mode where a fresh chat starts confidently but on the wrong assumptions.

## Reusable Prompt Blocks

### Conversation-End Summary Prompt

Use this when the user wants to compress a long thread into a reusable handoff:

```text
You are my context handoff assistant. Compress the conversation above into a reusable brief for a fresh GPT chat.

Goal:
Preserve only the information that is necessary for the next chat to continue the work accurately.

Requirements:
1. Remove greetings, repetition, tangents, and low-value intermediate steps.
2. Separate confirmed facts, assumptions, and preferences or constraints.
3. Keep only the information that materially affects the next answer.
4. If the conversation has multiple phases, preserve only the key milestone from each phase.
5. Use the exact output structure below.

Output structure:
- Core goal
- Background summary
- Confirmed facts
- Decisions made and why
- Attempts and outcomes
- Constraints and preferences
- Important entities or terms
- Open issues
- Next best actions
- Ready-to-paste fresh-chat kickoff prompt

Length:
- First produce a compact version in 300-800 words.
- If needed, add a short supplement after that.
```

### Fresh-Chat Kickoff Prompt

Use this after you already have a handoff summary:

```text
Below is the handoff summary from a previous conversation. Do not execute the task yet.

First:
1. Restate your understanding in 5-8 bullet points.
2. List missing information that would materially change the result.
3. Point out conflicts or uncertainty, prioritizing confirmed facts and constraints.
4. Propose the best execution path.
5. Wait for confirmation before starting the task if there are meaningful gaps.

Handoff summary:
"""
[paste summary here]
"""

My new task:
"""
[paste the current task here]
"""

Output order:
- Understanding
- Missing information or risks
- Proposed path
```

### Phase-by-Phase Compression Prompt

Use this when the original thread is very long or disorganized:

```text
The conversation above is too long and noisy to summarize well in one pass.

Please do this in two stages.

Stage 1:
- Summarize the early phase in 100-150 words
- Summarize the middle phase in 100-150 words
- Summarize the current phase in 100-150 words

For each phase, include:
- goal
- key decisions
- outcomes
- unresolved issues

Stage 2:
Merge those phase summaries into one final handoff brief using this structure:
- Core goal
- Confirmed facts
- Decisions made and why
- Constraints and preferences
- Open issues
- Next best actions
```

### Rolling Summary Prompt

Use this every 20-40 turns or after each major milestone:

```text
Create a rolling summary of the conversation so far.

Keep only:
- long-term context
- current phase context
- current request
- confirmed facts
- unresolved issues
- next action

Delete:
- repetition
- greetings
- low-value intermediate discussion
- information that no longer affects the next step

Limit the summary to 200-400 words and make it reusable in a later chat.
```

## Response Rules

When applying this skill:

- Prefer concise structure over long explanation.
- Do not dump the whole transcript back to the user.
- Keep facts, guesses, and preferences separate.
- If the user asks "how should I phrase it," give a short explanation plus a ready-to-paste prompt.
- If the user asks for the actual summary, produce the summary directly.
- If the user asks for a reusable system, include both the summary prompt and the kickoff prompt.
- If the user is building an API workflow, mention that automated context compaction or context management is the programmatic version of this workflow.

## Common Failure Modes

- Asking the model to "summarize everything above" with no schema
- Copying the entire transcript into the new chat
- Mixing facts, assumptions, and preferences together
- Letting the new chat begin execution before alignment
- Preserving wording instead of preserving state

## Quick Checklist

Before finishing, verify:

- `Long-term context` is captured
- `Phase context` is captured
- `Current request` is captured
- `Confirmed facts` are separated from guesses
- `Constraints and preferences` are explicit
- `Open issues` are visible
- `Next best actions` are clear
- A `fresh-chat kickoff prompt` is included when useful
