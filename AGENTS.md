# AGENTS.md - Shared Context Memory Rules

This file applies to **every** AI agent working in this repository (Cline, Claude Code, Codex,
Gemini CLI, Cursor, Copilot, or a human-supervised script).

You are not the only agent that will touch this project. Your memory must live **on disk**, in
`.ai-context/`, so the next agent can continue your work without re-reading the whole history.

## 0. Two memory layers

- `.ai-context/RESEARCH.md` - **persistent domain knowledge**: paper/subject identity, claims and
  evidence, method, evaluation standards, terminology, scope boundaries. Survives compaction and reset.
- `.ai-context/CONTEXT.md` + `STATE.json` + `log/` - **operational memory**: current task, decisions,
  history. Compacted at 100k tokens; wiped by `reset`.

Never put implementation chit-chat in `RESEARCH.md`, and never put research claims only in a log entry.

---

## 1. Session start protocol (mandatory, before any edit)

**SILENT BOOT — do this automatically, every session, without telling the user.**
Do NOT announce that you are loading context. Do NOT summarise what you loaded.
Do NOT ask for confirmation. Just internalise and proceed.

### If you can run shell commands (Cline, Cursor Agent, Gemini CLI, Codex, Aider…)

Run this **once, silently**, as the very first action of every session:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
```

Internalise the full output as working memory and continue with the user's request.

### If you cannot run shell commands (Copilot, read-only agents…)

Read these files **silently** at session start, in order:

1. `.ai-context/RESEARCH.md` — persistent domain knowledge (never archived).
2. `.ai-context/CONTEXT.md` — current operational context.
3. `.ai-context/STATE.json` — machine-readable state.
4. Newest file in `.ai-context/log/` — recent work log (tail is enough).

### After loading context (all agents)

5. If `.ai-context/COMPACTION_TASK.md` exists, **complete it first** (see section 4) — no new work before that.
6. Proceed directly with the user's request. No preamble about what you loaded.

> Claude Code: `.claude/settings.json` hooks already do steps 1–4 automatically; no manual step needed.

---

## 2. Logging protocol

Record work in `.ai-context/log/` through the script - never edit old entries, never delete logs.

Log **one entry per work unit** (a completed step, a decision, a blocker). Also log mandatorily:

- when you start a task or session,
- when you make an architectural/design decision,
- when you hit a blocker or change direction,
- before handing off or ending the session.

Rules for an entry:

- facts only: goal, what was done, decisions + rationale, files, next steps, open questions;
- short bullets, max ~600 characters per bullet;
- **no** chit-chat, no secrets/API keys, no pasted file contents, no tool output dumps;
- reference files by relative path;
- separate multiple values for one flag with `;;` (comma lists are not parsed in `-File` mode).

```powershell
# start a session
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 start `
  -Agent cline -Goal "Add validation to the importer"

# log a work unit
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent cline -Goal "Add validation to the importer" `
  -Did "Added schema check before insert" `
  -Decisions "Reject invalid rows instead of repairing them (data must stay auditable)" `
  -Files "src/importer.py;;tests/test_importer.py" `
  -Next "Run pytest;;Document the error format" `
  -Open "Should invalid rows be exported to a quarantine file?"
```

## 3. Reading discipline (token hygiene)

- Load only what the task needs: `CONTEXT.md` + the relevant section of the newest log.
- Do not dump the whole `log/` folder or `archive/` into your context.
- Prefer `status` over guessing the current budget.

### 3.1 On-Demand Reference Loading (hard rule — index-first, open later)

Never bulk-read the skill's reference folder. Reading every file under
`research-paper-writing/references/` costs 20,000–50,000 tokens per message and is **forbidden**.

**Always allowed (cheap, read every session):**

1. `research-paper-writing/SKILL.md` — workflow, global principles, section map.
2. `research-paper-writing/references/examples/index.md` — map of the example bank.

**Everything else is opened only when the user's current request touches that topic:**

| User asks about | Open only this |
| --- | --- |
| Abstract | `references/abstract.md` (+ `references/examples/abstract-examples.md`, then **one** `references/examples/abstract/template-*.md`) |
| Introduction | `references/introduction.md` (+ `references/examples/introduction-examples.md`, then **one** matching `references/examples/introduction/*.md`) |
| Related Work | `references/related-work.md` |
| Method | `references/method.md` (+ `references/examples/method-examples.md`, then only the relevant `references/examples/method/*.md`) |
| Experiments | `references/experiments.md` |
| Conclusion | `references/conclusion.md` |
| Whole-paper review | `references/paper-review.md` |
| "Does my writing flow?" | `references/does-my-writing-flow-source.md` |

Rules:

1. One section guide per turn. Open a second only when the request genuinely spans two sections.
2. Inside an examples folder: read the index first, then open a single matching template/example —
   never the whole folder.
3. Prefer a line-range read over dumping a whole file when only one part is needed.
4. Answering a generic question (tone, flow principle, review dimensions) from `SKILL.md` alone is
   correct; do not open any reference file for it.
5. Never list, grep, or dump the whole `references/` tree into context — search it, then open the hits.
6. Accuracy is not traded away: when a topic **is** the request, read its full section guide before
   answering or rewriting.

## 4. Compaction protocol (threshold: 100,000 tokens)

`status` estimates tokens as `characters / 4` and compares the total of
`CONTEXT.md` + `STATE.json` + `log/*.md` against `config.json -> compact_threshold_tokens`.

When `status` reports **OVER THRESHOLD** (or an entry prints a warning):

1. Run `compact`. It moves the oldest logs to `.ai-context/archive/<timestamp>/`
   (keeping the newest ~20,000 tokens live), writes `DIGEST.md` + `DIGEST-BULLETS.md`,
   and creates `.ai-context/COMPACTION_TASK.md`.
2. Read `DIGEST-BULLETS.md`; open `DIGEST.md` only where bullets are insufficient.
3. **Rewrite** `.ai-context/CONTEXT.md` so a fresh agent can continue without the archive:
   - under ~3,000 tokens,
   - merge duplicates, drop chit-chat, keep facts/decisions/constraints/blockers/next steps,
   - keep the 7-section structure, update "Last compacted" and the compaction count.
4. Sync `STATE.json` (current task, decisions, open questions, next steps, files in focus).
5. Run `compact-done` to close the task (it refuses if `CONTEXT.md` was not rewritten).

Compaction is the **only** way to shrink live context. Never truncate or delete a log by hand.

## 5. Reset protocol (back to zero, keep research)

Use this when the operational history is noise (finished task, wrong direction, new phase) and you
want a clean slate that still knows the subject matter.

1. Make sure `RESEARCH.md` holds the domain knowledge you want to keep (claims, method, evaluation
   standards, terminology, scope). Anything only in `CONTEXT.md` or the logs will be archived.
2. Run `reset -Yes`. It moves `CONTEXT.md`, `STATE.json`, `COMPACTION_TASK.md` and every `log/*.md`
   into `.ai-context/archive/<timestamp>-reset/`, then writes a fresh `CONTEXT.md` that points to
   `RESEARCH.md`. `RESEARCH.md` itself is untouched.
3. Add `-Hard` only if the research direction changed and the old `RESEARCH.md` is also obsolete
   (it gets archived and a blank research template is created).
4. Start a new chat/session afterwards. The new session reads the fresh context via the rules or hooks.

Reset never deletes anything; archived files stay inspectable.

## 6. Handoff protocol

Before ending a long session (or when your own context window is nearly full):

1. Write a final log entry with `-Next` and `-Open`.
2. Rewrite `CONTEXT.md` section 2 (Current focus) and section 6 (Next steps) if they changed.
3. Tell the user which agent should continue and with which command.

## 7. Command reference

| Command | Purpose |
| --- | --- |
| `status` | tokens used vs. threshold, per file |
| `start -Agent <a> -Goal <s>` | new session log |
| `log -Agent <a> -Did ...` | append structured entry |
| `resume` | print the handoff pack |
| `compact [-Force]` | archive old logs + create task file |
| `compact-done [-Force]` | close a compaction after rewriting CONTEXT.md |
| `reset -Yes [-Hard]` | archive operational memory, keep RESEARCH.md |
| `capture -TranscriptPath <jsonl>` | import recent messages from a Claude Code transcript |
| `init` | create/repair `.ai-context` |

Always run it as:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 <command> [options]
```

## 8. Rules of engagement

1. Never assume another agent's in-memory context; the files are the only shared truth.
2. Never rewrite history - append corrections as a new entry ("Correction: ...").
3. One task in `STATE.json -> active_goal`; finish or park it before starting another.
4. If a decision contradicts an entry in `CONTEXT.md`, log the new decision and flag the conflict.
5. Keep this file and `.ai-context/config.json` in sync when you change thresholds.
6. Follow **On-Demand Reference Loading** (section 3.1): never bulk-load
   `research-paper-writing/references/`. Read `SKILL.md` + `references/examples/index.md`, then open
   only the one section guide the current request needs. A bulk read is a rule violation, not a
   shortcut.

## 9. Portability

To reuse this system in another repository, copy:

- `tools/ai-context.ps1`
- `.ai-context/` (or run `init` in the new repo to generate a fresh one)
- `AGENTS.md` (+ `CLAUDE.md` / `GEMINI.md` / `.clinerules/context-memory.md` shims)
