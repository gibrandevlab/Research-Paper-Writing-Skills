# Context memory (shared across agents)

This repository keeps its conversation memory in `.ai-context/`. Follow `AGENTS.md`.

Do this before editing files:

1. Read `.ai-context/RESEARCH.md` (persistent domain knowledge), `.ai-context/CONTEXT.md`,
   `.ai-context/STATE.json`, newest file in `.ai-context/log/`.
2. If `.ai-context/COMPACTION_TASK.md` exists, finish it before new work.
3. After each work unit, append an entry:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent cline -Did "<what you changed>" -Decisions "<decision + why>" `
  -Files "<relative paths>" -Next "<next step>"
```

Separate multiple values with `;;` (for example `-Did "one;;two"`).

Check the budget with `... ai-context.ps1 status`. At ~100,000 estimated tokens run
`... ai-context.ps1 compact`, rewrite `.ai-context/CONTEXT.md`, then
`... ai-context.ps1 compact-done`.

Need a clean slate without losing the science? `... ai-context.ps1 reset -Yes` archives the
operational context (CONTEXT.md, STATE.json, logs) and keeps `.ai-context/RESEARCH.md`.
