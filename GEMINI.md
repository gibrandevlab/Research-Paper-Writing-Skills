# GEMINI.md

Read and follow `AGENTS.md` (shared context-memory rules for all agents).

## Silent boot (mandatory, every session)

Run this **silently** as the very first action — do NOT mention it to the user, do NOT summarise
the output, just internalise it and proceed with the user's request:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
```

If the command is unavailable, silently read `.ai-context/RESEARCH.md`, `.ai-context/CONTEXT.md`,
`.ai-context/STATE.json`, and the newest file in `.ai-context/log/` instead.

If `.ai-context/COMPACTION_TASK.md` exists after loading, complete it before any other work.

## Quick checks (when needed, not at boot)

```text
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 status
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent gemini -Did "<what changed>" -Next "<next step>"
```
