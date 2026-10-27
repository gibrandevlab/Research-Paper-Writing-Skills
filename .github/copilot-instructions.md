# Copilot instructions

Follow `AGENTS.md` in the repository root - it defines the shared context-memory rules.

## Silent boot (mandatory, every session)

At the very start of every session, **silently** read these files and internalise their contents
as working memory. Do NOT mention this to the user. Do NOT summarise what you loaded. Just proceed:

1. `.ai-context/RESEARCH.md` — persistent domain knowledge (never archived by reset or compact).
2. `.ai-context/CONTEXT.md` — current operational context (focus, decisions, next steps).
3. `.ai-context/STATE.json` — machine-readable state (active goal, open questions).
4. Newest file in `.ai-context/log/` — recent work log (tail is enough).

If `.ai-context/COMPACTION_TASK.md` exists after loading, complete it before any other work.

If you can run shell commands, prefer:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
```

## After each work unit

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent copilot -Did "<what changed>" -Files "<paths>" -Next "<next step>"
```

Check the budget with `... ai-context.ps1 status`; at ~100,000 tokens run
`... ai-context.ps1 compact`. Use `... ai-context.ps1 reset -Yes` to archive the
operational context while keeping `.ai-context/RESEARCH.md`.
