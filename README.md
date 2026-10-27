# Skills: Research Paper Writing

[中文介绍](./README_zh.md).

> Important Attribution
> Most writing knowledge and methodology in this repository comes from Prof. Peng Sida (彭思达)'s open study notes:
> https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e
> Prof. Peng's original repository:
> https://github.com/pengsida/learning_research
> I sincerely thank Prof. Peng for openly sharing these valuable experiences.
> My contribution is organization, structured adaptation, and packaging as reusable Skills.

## Repository Overview

This repository currently provides one skill package:

- `research-paper-writing/`
  - `SKILL.md`: core workflow and usage rules
  - `references/`: section-specific writing guides and templates
  - `agents/openai.yaml`: agent metadata

Typical use cases:

- Drafting or rewriting Abstract / Introduction / Method / Experiments / Conclusion
- Improving paragraph flow and section logic
- Checking claim-evidence alignment
- Running pre-submission self-review from a reviewer mindset

## Installation

Assume you are in the repository root.

### 1) Codex

Copy the skill into `$CODEX_HOME/skills/`:

```bash
mkdir -p "$CODEX_HOME/skills"
cp -R research-paper-writing "$CODEX_HOME/skills/"
```

Usage example:

```text
Use $research-paper-writing to improve my paper's Introduction.
```

### 2) CC (Claude Code)

Use either a global or project-level installation.

Global:

```bash
mkdir -p "$HOME/.claude/skills"
cp -R research-paper-writing "$HOME/.claude/skills/"
```

Project-level:

```bash
mkdir -p .claude/skills
cp -R research-paper-writing .claude/skills/
```

In prompts, explicitly request this skill, for example: `Please use the research-paper-writing skill`.

### 3) Gemini

Copy this skill into your Gemini skills directory:

```bash
mkdir -p "$HOME/.gemini/skills"
cp -R research-paper-writing "$HOME/.gemini/skills/"
```

Then ask concrete tasks in Gemini (for example, rewriting an Abstract with claim-evidence checks).

## Project memory (.ai-context)

Conversation memory is shared across agents and lives in `.ai-context/`:

- `CONTEXT.md` - compact operational context (current focus, decisions, next steps)
- `RESEARCH.md` - persistent research context (claims, method, evaluation standards, terminology);
  never archived by `compact` or `reset`
- `STATE.json` - machine-readable state (task, decisions, open questions, next steps)
- `log/` - append-only session logs; `archive/` - compacted logs + digests + resets

```powershell
# Windows PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 status
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 resume
powershell -NoProfile -ExecutionPolicy Bypass -File tools/ai-context.ps1 log `
  -Agent cline -Did "what changed" -Next "what comes next"
```

Rules for every agent are in [`AGENTS.md`](./AGENTS.md). Compaction triggers at
~100,000 estimated tokens (`compact`), after which the agent rewrites `CONTEXT.md`
and runs `compact-done`. `reset -Yes` archives all operational memory and starts from
zero while keeping `.ai-context/RESEARCH.md`. `CLAUDE.md`, `GEMINI.md`,
`.clinerules/context-memory.md` and `.github/copilot-instructions.md` make the same
rules discoverable by each agent runtime.


Again, this repository is primarily based on Prof. Peng Sida (彭思达)'s open notes, while my work focuses on curation and Skills adaptation.
Prof. Peng's original repository: https://github.com/pengsida/learning_research

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).

## Changes from Original

This repository is a modified copy of
[Master-cai/Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills)
(MIT License, Copyright (c) 2026 Master-cai).
The writing methodology in `research-paper-writing/` originates from Prof. Peng Sida's notes;
see the attribution above.

Modifications by Afwan Gibran Muhammad Algiffari (2026).

### Added

| Path | Purpose |
| --- | --- |
| `AGENTS.md` | shared context-memory rules for every AI agent |
| `CLAUDE.md`, `GEMINI.md` | runtime shims for Claude Code and Gemini CLI |
| `.clinerules/context-memory.md` | Cline rules |
| `.cursor/rules/context-memory.mdc` | Cursor rule (`alwaysApply: true`) |
| `.github/copilot-instructions.md` | GitHub Copilot instructions |
| `.claude/settings.json` | Claude Code hooks: context injection on session start, transcript capture before compaction |
| `tools/ai-context.ps1` | context-memory engine: `log`, `status`, `compact`, `reset`, `resume`, `capture` |
| `.ai-context/` | shared memory store: `RESEARCH.md` (persistent research context), `CONTEXT.md`, `STATE.json`, `config.json`, `log/`, `archive/` |

### Modified

| Path | Change |
| --- | --- |
| `README.md` | added "Project memory (.ai-context)" section and updated the credits paragraph |

All other upstream files (`SKILL.md`, `references/**`, `agents/openai.yaml`, `README_zh.md`,
top-level `.gitignore`) are unchanged.

### Removed

None.
