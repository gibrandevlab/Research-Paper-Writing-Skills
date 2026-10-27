# CLAUDE.md

@AGENTS.md

## Claude Code specifics

- Project memory lives in `.ai-context/`. `.claude/settings.json` hooks **already handle the
  silent boot automatically** — context is injected before your first response every session.
  No manual step needed.
- To restart with zero operational context but the same research knowledge, run
  `powershell ... tools/ai-context.ps1 reset -Yes` (archives CONTEXT/STATE/logs, keeps `RESEARCH.md`).
- `.claude/settings.json` registers two hooks (Windows):
  - `SessionStart` → silently injects `CONTEXT.md`, `STATE.json` and the newest log into
    your context window before you respond. The user never sees this.
  - `PreCompact` → captures the transcript into `.ai-context/log/` before compaction so
    nothing is lost.
- `/compact` is only a chat-level operation. Durable context must already be in
  `.ai-context/`; use the logging rules in `AGENTS.md`.
- When you finish a compaction, run
  `powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 compact-done`.
