---
name: report-skill-gap
description: Use when, while using ANOTHER skill, you hit an objective gap in it — you contradicted an explicit instruction in that skill, it gave no guidance for a situation you were forced to handle, or you caught yourself rationalizing around one of its rules — and you want to file a structured feedback report back to the skills repo. NOT for normal successful use or mere preference.
disable-model-invocation: true
---

# report-skill-gap

## Overview

File a **structured gap report** against another skill so the skills repo can fix it
through its RED→GREEN→guards loop. The report is a **RED-test hypothesis, not an edit** —
you produce a clean, copy-pasteable artifact; a human relays it; the repo's dev session
verifies and acts. You never edit the other skill.

## You're here because the user invoked `/report-skill-gap`

This skill never fires autonomously (`disable-model-invocation: true`) — the user
typing the command IS the consent. Reconstruct the gap from the conversation: which
skill, what situation (S), what it did (A), what it should have done (E). **If no
qualifying trigger below holds, say so plainly and stop** — don't manufacture a report
to justify the invocation.

## When to file — objective triggers ONLY

File **only** when, while using a skill, one of these held:
1. You took an action that **contradicted an explicit instruction** in the skill.
2. The skill **gave no guidance** for a situation you were forced to handle.
3. You **caught yourself rationalizing** around one of the skill's rules.

**Do NOT file** for normal successful use, a feature you'd merely prefer, or any gripe you
cannot tie to a specific instruction or a specific missing-guidance situation. **If you
cannot name the instruction contradicted OR the missing-guidance situation, it is
preference, not a defect — stop.**

## Sanitize before you emit — the report may go public

You saw proprietary project context; the skills repo may be published. **Abstract**
`trigger`/`repro`/`quote` to the **skill-relevant shape** and strip secrets, credentials,
PII, customer names, internal hostnames, and raw proprietary content. Example: replace
`POST https://internal-billing.acme.corp/charge` with `<an authenticated POST to an
internal billing endpoint>`. **If you cannot sanitize without losing the gap, do not
file.** (The repo re-scrubs as well — but you are the first layer.)

## The report — emit this exact block

Produce one fenced `skill-feedback` block. **Required:** `skill`, `trigger` (S),
`actual` (A), `expected` (E) — phrasable as *"in S, the skill did A but should have done
E"* — and `contradicts:` naming the explicit instruction broken OR "no guidance for X".
Agent-source **should** add an abstracted `repro` seed and (only if verbatim) `quote`.
Optional `severity`/`suggestion`. Auto-fill `source`/`when`.

```skill-feedback
skill:      <name>
trigger:    <S>
actual:     <A>
expected:   <E>
contradicts: <explicit instruction broken, OR "no guidance for X">
repro:      <abstracted seed>
quote:      "<verbatim only; else omit>"
severity:   low | medium | high
suggestion: <non-binding>
source:     agent
when:       <YYYY-MM-DD>
```

**Always surface the block to the human**, tagged `📋 SKILL-GAP REPORT — send it where
your skills collection's CONTRIBUTING says (open an issue, or DM the maintainer)`. Never
bury it in prose. The human relays it; the repo verifies and runs RED→GREEN→guards.

## Red flags — STOP

- Filing on normal use or mere preference (no nameable contradiction / missing-guidance).
- A `trigger`/`actual`/`expected` that can't be phrased as the testable sentence.
- A report missing the fenced block (unstructured prose the repo can't consume).
- Manufacturing a report when no objective trigger holds (invocation is not evidence of a gap).
- Any field containing a secret, credential, PII, customer name, or internal hostname.
