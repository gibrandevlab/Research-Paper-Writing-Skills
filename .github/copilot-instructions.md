# Copilot instructions

Follow `AGENTS.md` in the repository root - it defines the shared context-memory rules.

Before editing files:

1. Read `.ai-context/RESEARCH.md` (persistent research context) and `.ai-context/CONTEXT.md`.
2. Read `.ai-context/STATE.json` and the newest file in `.ai-context/log/`.
3. If `.ai-context/COMPACTION_TASK.md` exists, finish it first.
4. After each work unit, append an entry:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent copilot -Did "<what changed>" -Files "<paths>" -Next "<next step>"
```

Check the budget with `... ai-context.ps1 status`; at ~100,000 tokens run
`... ai-context.ps1 compact`. Use `... ai-context.ps1 reset -Yes` to archive the
operational context while keeping `.ai-context/RESEARCH.md`.
