# Skills: Research Paper Writing

**Language / 语言 / 言語 / اللغة:**
[中文](./README_zh.md) | [Bahasa Indonesia](./README_id.md) | [日本語](./README_ja.md) | [العربية](./README_ar.md)

> **Important Attribution**
> Most writing knowledge and methodology in this repository comes from Prof. Peng Sida (彭思达)'s open study notes:
> https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e
> Prof. Peng's original repository:
> https://github.com/pengsida/learning_research
> I sincerely thank Prof. Peng for openly sharing these valuable experiences.
> My contribution is organization, structured adaptation, and packaging as reusable Skills.

---

## What Is This?

This repository gives your AI assistant **deep knowledge of academic paper writing** — based on the methodology of Prof. Peng Sida, a leading AI researcher.

After a one-time setup, just **ask your AI as you normally would**. The AI will automatically:
- Guide you through writing Abstract / Introduction / Method / Experiments / Conclusion
- Improve paragraph flow and section logic
- Check claim-evidence alignment
- Perform pre-submission self-review from a reviewer's perspective

---

## Quick Setup (3 Steps, Done Once)

### Step 1 — Clone this repository

**Windows:**
```powershell
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

**Mac / Linux:**
```bash
git clone https://github.com/gibrandevlab/Research-Paper-Writing-Skills.git
cd Research-Paper-Writing-Skills
```

> Don't have Git? Download at https://git-scm.com/downloads

---

### Step 2 — Install to your AI editor

#### Gemini (Google)
```powershell
# Windows
xcopy /E /I research-paper-writing "%USERPROFILE%\.gemini\skills\research-paper-writing"
```
```bash
# Mac / Linux
cp -R research-paper-writing ~/.gemini/skills/
```

#### Claude Code / Cline
```powershell
# Windows (global)
xcopy /E /I research-paper-writing "%USERPROFILE%\.claude\skills\research-paper-writing"
```
```bash
# Mac / Linux (global)
cp -R research-paper-writing ~/.claude/skills/
```

#### Cursor
Open Cursor → Settings → AI → add the `research-paper-writing` folder path to the Skills directory.

#### Codex (OpenAI)
```bash
mkdir -p "$CODEX_HOME/skills"
cp -R research-paper-writing "$CODEX_HOME/skills/"
```

---

### Step 3 — Open your AI editor and start asking

**Done.** Nothing else to configure. Your AI will automatically know how to help.

---

## Daily Usage

Just open your AI editor and ask directly — no special commands, no need to remember any tool names.

**Writing an Abstract:**
> "Help me write an abstract. My paper's main contribution is a new method for 3D object detection that is 2× faster than SOTA."

**Improving Introduction:**
> "My introduction doesn't flow well. Can you review and improve it?"

**Checking Method section:**
> "Does my Method section clearly explain why module X is needed?"

**Pre-submission review:**
> "Please review my paper from the perspective of a CVPR reviewer."

The AI responds with structured, expert guidance — **you don't need to know any tool names, commands, or configurations**.

---

## Supported AI Editors

| AI / Editor | Status |
|---|---|
| Claude Code | ✅ Fully automatic |
| Gemini / Antigravity | ✅ Fully automatic |
| Cursor | ✅ Automatic (rules always active) |
| Cline | ✅ Fully automatic |
| GitHub Copilot | ✅ Automatic (reads context on session start) |
| OpenAI Codex | ✅ Full support |
| Any other agent | ✅ Manual mode (ask AI to load context) |

---

## Cross-Session Memory (.ai-context)

This repository includes a shared memory system. This means:
- Working on the same paper across different AI editors? **All AIs share the same context.**
- AI won't "forget" what was discussed in a previous session.
- Switch from Cursor to Claude Code? No problem — the context carries over.

This all happens **automatically in the background** — you don't need to do anything.

> **For developers / technical users:** see [AGENTS.md](./AGENTS.md) for the full context-memory protocol and `tools/ai-context.ps1` command reference.

---

## Credits

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
| `README_id.md`, `README_ja.md`, `README_ar.md` | localized READMEs for non-technical researchers |

### Modified

| Path | Change |
| --- | --- |
| `README.md` | non-technical quick-start, multi-language links, cross-session memory section |
| `README_zh.md` | updated with multi-language links and non-technical quick-start |

### Removed

None.
