# Research Context (persistent)

> Domain knowledge that must survive compaction and context resets.
> Never archived by `compact` or `reset` (only `reset -Hard` moves it).
> Keep under ~2,000 tokens. Update it when the subject matter changes, not when tooling changes.
> Read together with `.ai-context/CONTEXT.md` at session start.

## 1. Subject / paper identity

- Subject: how to write and revise ML / CV / NLP research papers.
- Scope: the skill pack `research-paper-writing/` (adapted from Prof. Peng Sida's notes).
- Audience: an AI agent acting as writing partner for a human author.
- Working title / venue: not applicable - this repository produces guidance, not a paper.

## 2. Core claims and evidence

| # | Claim | Evidence (file / section) | Status |
| --- | --- | --- | --- |
| 1 | Section-first drafting (Abstract -> Intro -> Method -> Experiments) keeps the story coherent | `SKILL.md` workflow, `references/introduction.md` | active |
| 2 | Every claim must map to evidence; unsupported claims are the main rejection cause | `SKILL.md` output contract, `references/paper-review.md` | active |
| 3 | Introductions follow task -> challenge -> method -> advantage, not chronology | `references/introduction.md` logic map | active |
| 4 | Module design must be justified by motivation and technical advantage | `references/method.md` triad | active |

## 3. Method knowledge (stable)

The skill enforces a fixed **output contract** for every edit request:
(1) 3-7 bullet section outline, (2) revised paragraphs labelled by rhetorical role
(opening / challenge / method / advantage / evidence / limitation), (3) a self-review
checklist (clarity, flow, term consistency, unsupported claims), and (4) a
Claim-Evidence map table `Claim | Evidence | Status`.
It loads exactly one reference file per request to avoid context bloat.

## 4. Evaluation standards

- Rejection dimensions (`references/paper-review.md`): unclear contribution, unsupported claims,
  weak baselines, missing ablations, poor writing/flow.
- Flow test: every paragraph must answer "why does the reader need this now?"
- Term consistency: one name per concept across abstract, method, experiments, conclusion.
- Numbers: every reported metric is comparable, has a direction (higher/lower is better),
  and appears in both text and table.

## 5. Key results

Not applicable (no experiments). Quality signal = revised text passes the self-review checklist
and the Claim-Evidence map has no `unsupported` rows.

## 6. Terminology and conventions

| Term / symbol | Meaning | First defined in |
| --- | --- | --- |
| Claim-Evidence map | table linking each claim to the artifact that proves it | `SKILL.md` |
| Rhetorical role | function of a paragraph in the argument | `SKILL.md` output contract |
| Flow test | reader-necessity check between paragraphs | `references/does-my-writing-flow-source.md` |
| Triad (method) | Module Design / Motivation / Technical Advantage | `references/method.md` |

## 7. Scope boundaries

- Claims this work does NOT make: it does not generate results, run experiments, or replace a supervisor.
- Known limitations: Markdown-only pack; no automatic citation checking; ASCII-safe generated files.
- Never fabricate numbers, citations, or ablations to satisfy a template.

## 8. Key references

- `research-paper-writing/SKILL.md`
- `research-paper-writing/references/abstract.md`, `introduction.md`, `method.md`,
  `experiments.md`, `related-work.md`, `conclusion.md`, `paper-review.md`,
  `does-my-writing-flow-source.md`
- `research-paper-writing/references/examples/` (templates)
