---
name: karpathy-guidelines
description: Coding discipline that stops the usual LLM coding mistakes - silent wrong assumptions, overbuilt code, drive-by edits to unrelated lines, and vague goals. Use whenever writing, changing, reviewing, refactoring or debugging code in any project - websites, apps, scripts, automations, hooks, skills. Surface assumptions, write the minimum that solves the problem, touch only what the task needs, and turn every task into a verifiable check before calling it done.
license: MIT
---

# Karpathy Guidelines — coding discipline

Project build of `andrej-karpathy-skills` (Forrest Chang, MIT,
[multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)
@ `2c60614`), distilled from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876)
on how LLMs go wrong when they code. Four rules, unchanged in substance; the section
below says how they apply in this repo.

## Scope in this repo

- **Applies to:** every code change here — `skills/watch/scripts/*.py`, `hooks/`, the
  build script, tests, manifests. This is a **dev-time skill**: `.skillignore` lists
  `.claude/`, so it never ships inside the published `watch` package.
- **Outranked by:** the user's explicit instruction and `AGENTS.md` (structure, the
  harness-agnostic path rules, and version-sync rules win over anything here).
- **Verify with:** the pytest suite (`.venv/bin/pytest -q`) and, for packaging changes,
  `bash skills/watch/scripts/build-skill.sh`. Goal-driven execution (rule 4) means a
  failing test or build first, then the fix.
- **Two reconciliations** (these rules would otherwise fight a "don't ask needless
  questions, fix obvious problems" working style):
  1. *"If uncertain, ask"*: ask only when the answer would change what gets built.
     Otherwise state the assumption in one line, take the reasonable default, proceed.
  2. *"Don't improve adjacent code"*: stay surgical inside a change. Anything else you
     notice — dead code, a latent bug, a better structure — gets reported or proposed
     as its own change, never mixed into the same diff.

**Tradeoff:** these rules bias toward caution over speed. For a trivial one-line change,
use judgment.

## 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain in a way that changes the result, ask.
- If several interpretations exist, name them — don't pick one silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop and name exactly what is confusing.

## 2. Simplicity first

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" nobody requested.
- No error handling for impossible scenarios.
- If it's 200 lines and could be 50, rewrite it.

Test: would a senior engineer call this overcomplicated? If yes, simplify.

## 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments or formatting.
- Don't refactor what isn't broken.
- Match the existing style, even where you'd choose differently.
- Unrelated dead code: mention it, don't delete it.
- Remove imports, variables and functions that *your* change made unused; leave
  pre-existing dead code unless asked.

Test: every changed line traces directly to the request.

## 4. Goal-driven execution

**Define success criteria. Loop until verified.**

Turn the task into a check:

- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Refactor X" → tests pass before and after.

For multi-step work, state a short plan with a check per step:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Strong criteria let you loop independently; "make it work" forces constant clarification.

## Working if

Diffs carry fewer unnecessary changes, fewer rewrites come from overcomplication, and
clarifying questions arrive before implementation rather than after a mistake.

Worked before/after examples for each rule: [references/examples.md](references/examples.md).
