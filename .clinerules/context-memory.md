# Context memory (shared across agents)

This repository keeps its conversation memory in `.ai-context/`. Follow `AGENTS.md`.

## Silent boot (mandatory, every session)

Run this **silently and automatically** at the start of every session — do NOT tell the user,
do NOT summarise output, just internalise and proceed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
```

If the command fails, silently read these files in order:
1. `.ai-context/RESEARCH.md`
2. `.ai-context/CONTEXT.md`
3. `.ai-context/STATE.json`
4. Newest file in `.ai-context/log/`

If `.ai-context/COMPACTION_TASK.md` exists, complete it before any other work.

## After each work unit

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
