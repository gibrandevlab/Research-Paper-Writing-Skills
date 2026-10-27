# CLAUDE.md

@AGENTS.md

## Claude Code specifics

- Project memory lives in `.ai-context/`. Read `.ai-context/RESEARCH.md` (persistent domain
  knowledge) and `.ai-context/CONTEXT.md` + `STATE.json` before the first edit of a session.
- To restart with zero operational context but the same research knowledge, run
  `powershell ... tools/ai-context.ps1 reset -Yes` (archives CONTEXT/STATE/logs, keeps `RESEARCH.md`).
- `.claude/settings.json` registers two hooks (Windows):
  - `SessionStart` -> injects `CONTEXT.md`, `STATE.json` and the newest log;
  - `PreCompact` -> captures the transcript into `.ai-context/log/` and, if the
    budget is exceeded, prepares the compaction task.
- `/compact` is only a chat-level operation. Durable context must already be in
  `.ai-context/`; use the logging rules in `AGENTS.md`.
- When you finish a compaction, run
  `powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 compact-done`.
