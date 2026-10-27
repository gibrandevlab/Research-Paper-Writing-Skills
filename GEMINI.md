# GEMINI.md

Read and follow `AGENTS.md` (shared context-memory rules for all agents).

Before any edit in this repository:

1. Read `.ai-context/RESEARCH.md` (persistent domain knowledge), `.ai-context/CONTEXT.md`,
   `.ai-context/STATE.json`, and the newest file in `.ai-context/log/`.
2. If `.ai-context/COMPACTION_TASK.md` exists, complete it first.
3. Log each work unit with `tools/ai-context.ps1 log` (see `AGENTS.md` section 2).

Quick checks:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 status
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
```
