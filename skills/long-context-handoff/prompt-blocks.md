# Long Context Handoff — Prompt Blocks

Reusable prompt templates referenced from [SKILL.md](SKILL.md). Copy and paste these directly into AI conversations.

## Conversation-End Summary Prompt

Use this when compressing a long thread into a reusable handoff:

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

## Fresh-Chat Kickoff Prompt

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

## Phase-by-Phase Compression Prompt

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

## Rolling Summary Prompt

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
