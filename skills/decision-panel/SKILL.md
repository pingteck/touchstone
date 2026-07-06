---
name: decision-panel
description: Use when you have a genuinely contested tradeoff with two or more viable options and need to reach a decision — "which should we pick", "X vs Y", "help us choose", "we can't decide between", weighing options, picking an architecture/library/vendor/approach, a decision with real pros and cons on each side. For a decision NOT yet made; if it's already decided and you want it stress-tested, that's red-team.
---

# Decision-Panel

## Overview

Deliberate **competing options** to *reach* a decision. Advocates make the strongest
principled case for each option and **honestly concede** where another is right; factual
cruxes are **verified, not asserted**; an **independent check** guards the synthesis; and
the call is made **by an explicit principle, not by vote** — preserving *what you lose*.

**Core principle: decide by principle, verify the facts, preserve the dissent.** A
recommendation is only as good as (a) the yardstick it's measured against and (b) the
evidence under its load-bearing facts. Vote-counting and midpoint-splitting are failures.

`decision-panel` helps you *decide*; its sibling `red-team` *breaks a decision already
made*. Don't confuse them (see guards).

## When to use / guards

Use when an artifact presents a **contested tradeoff** (≥2 viable options, decision not
yet made) and you want a principled, evidence-grounded call.

**Guards — fail honestly:**
- **Not actually contested** (one option clearly dominates) → say so and recommend the
  obvious; don't theater a deliberation.
- **Already converged / a single settled design** → that's **`red-team`**; hand off.
  *(Tie-breaker, stated identically in both skills: if any option is still genuinely
  open, `decision-panel` owns it; only a fully-settled single design goes to `red-team`.)*
- **No decision principle establishable** → present the tradeoff **without a fake
  verdict**; never midpoint-split.
- **>~4 options** → narrow first by applying the hard constraints as gates (§0); surface
  the dropped options + reason. Don't spin up many advocates.

## Flow

```
[0] FRAME (confirm with human) → [1] one advocate per option → [2] bounded adaptive
rounds (mechanical concession-based stop) → [3] crux resolution (decompose; verify
factual) → [4] mediator drafts synthesis BY PRINCIPLE → [5] independent synthesis-check
→ report
```

Reasoning-heavy: dispatch every subagent with an explicit `model` — an opus-class or
stronger reasoning model (an explicit user model choice always wins; the footer names
the model).
A-priori cost ≈ `options × rounds + factual claims verified (cruxes + load-bearing
synthesis claims) + 2` (mediator + synthesis-check); state it up front and report
actuals.

## [0] Frame — gather, don't invent

Confirm with the human (or infer-from-context — CLAUDE.md, vision/README, the decision's
goals — **and confirm**):
- **Question + viable options (≥2).**
- **Decision principle** — the optimization yardstick. **If inferred, present it with the
  alternatives it was chosen over** ("I inferred 'minimize operational surface'; others
  were 'maximize performance' / 'fastest to ship' — confirm which"), so confirmation is a
  real choice, not a rubber-stamp.
- **Hard constraints** — pass/fail **gates**, applied first. **Surface each
  classification** ("treating self-hostable as a hard gate — confirm or downgrade to a
  principle dimension"); an advocate may challenge a gate as miscalibrated in round 1.
- **Stakes & reversibility** (one-way vs two-way door) — calibrates depth; **gates the
  verdict** (§5).

**Constraints ≠ principle:** a gate eliminates regardless of merit; the principle ranks
what survives the gates.

## [1] Advocates & [2] bounded adaptive rounds

- **One advocate per option**, assigned, built from **symmetric, option-neutral prompt
  templates** (same structure + length budget; each option's framing from the *frame*,
  not the mediator's paraphrase — so no option is under-steelmanned). Flat instructions,
  not personas.
- **Advocate capabilities:** read-only file access; no write access; do not use the
  Agent tool to spawn sub-agents.
- Each builds the **strongest principled case** and **honestly engages the others**,
  emitting structured tags each round: **CONCEDE** (withdraws/qualifies a previously
  asserted claim), **HOLD**, **COUNTER**, **NEW-CRUX**.
- **Mechanical stop:** stop when a round adds **no new CONCEDE and no new NEW-CRUX** —
  read from the tags, *not* judged by the mediator. Hard cap ~3 rounds. **Persistent
  deadlock** (all HOLD, nothing new) is *not* "resolved" — escalate its cruxes to the
  principle.

## [3] Crux resolution — decompose, then verify the facts

A crux is where advocates won't concede. For **each crux**:

1. **Decompose** it into factual sub-claims + a residual value question. A crux isn't
   resolved until its factual part carries a tag.
2. **Verify each factual sub-claim** with a **separate-context verifier subagent**
   (its independence is non-negotiable — it catches the producer's own hallucinated
   evidence). **REQUIRED: read `references/verifier-contract.md` (in this skill's
   directory) and include it verbatim in the verifier's dispatch prompt.** In short:
   repo claims pinned `path:line` + snippet; external claims URL + exact quote; tag
   `[VERIFIED]` / `[REFUTED]` / `[UNCONFIRMED]`; **demote what you can't confirm.**
3. **Verify now, not later.** A checkable fact may not be deferred to "they should
   test it later" or parked in the revisit trigger.
4. **Carry the residual value question** to the mediator; the principle resolves it.

**Default verification scope — two categories, both required:**

- **(a) Crux factual claims** — every factual sub-claim from step 1.
- **(b) Load-bearing synthesis claims** — every factual claim the synthesis itself
  rests on: the facts under the recommendation's cost framing and the "what you lose"
  (output slots 3 & 6), **even if no advocate contested it.**

A claim is **load-bearing** when the recommendation, or the cost you state for it,
changes if the claim is false. An uncontested advocate FOR-claim you lean on as your
deciding cost **is load-bearing.**

Human opt-in **"verify all factual claims"** widens (b) to *every* factual claim.

## [4] Mediator synthesis

The mediator is the main thread — the contract binds the orchestrator.

- Draft the call **by principle, not vote**; you **may override the advocate
  majority** if a minority's reasoning best serves the principle.
- The facts under your **own** cost framing and "what you lose" are §3 category-(b)
  claims, **in scope for verification** — not free assertions. An uncontested
  advocate claim you now lean on is still a claim.
- Verify the checkable ones now, or tag them `[UNCONFIRMED]` — don't relabel them
  "assumption" and move on.

## [5] Independent synthesis-check

Dispatch a **separate-context subagent** before emitting the verdict. (Capabilities:
read-only access to the transcripts and repo; no write access; do not use the Agent
tool to spawn sub-agents.) It re-reads the advocate transcripts and confirms:

- each **claimed concession / crux resolution** actually occurred (catches a mediator
  hallucinating "B conceded latency");
- the **principle was applied** as stated (not silently swapped);
- the **frontrunner's strongest *unrebutted* weakness** is named (so good-faith
  concession can't quietly become groupthink);
- **every load-bearing factual claim** in the recommendation's cost framing and the
  "what you lose" (slots 3, 6) **carries a verification tag** — checked now (separate
  context, §3 contract), not asserted from memory, not parked in the revisit trigger.
  An untagged load-bearing claim **fails the check**;
- the **one-way-door guard** below holds.

If the check fails, the mediator **revises** (verifies or demotes) before emitting.

**One-way-door guard:** an **irreversible** decision whose **deciding crux is
`[UNCONFIRMED]`** may **not** emit a clean recommendation. Either return **"decision
blocked — verify crux Z empirically first,"** or rest the call **explicitly on the
stated assumption** with a **hard revisit trigger.**

## Output contract — REQUIRED slots, in order

1. **Frame (restated)** — question, options, **confirmed principle** (+ alternatives it
   beat, if inferred), constraints (+ classification), stakes/reversibility, any
   gate-dropped options.
2. **Constraint check** — which options passed/failed the gates (applied first).
3. **Recommendation — by principle** — one clear call: *"X, because it best serves
   «principle»."* If it **overrides the advocate majority**, say why the minority won.
   **Any load-bearing factual claim in the cost framing carries a verification tag**
   (verified now, not deferred). Subject to the one-way-door guard.
4. **Crux resolution** — each crux decomposed: factual sub-claims → verdict + pinned
   evidence/tag; value residual → resolved by principle.
5. **Concession trace** — per round, from the structured tags; **every advocate's
   position accounted for** (no advocate silently dropped).
6. **What you lose** — strongest case for the road not taken; the frontrunner's
   unrebutted weakness named by the synthesis-check. **Each load-bearing factual claim
   here is verified now and tagged** (or `[UNCONFIRMED]` + demoted) — never asserted from
   memory because "it wasn't a crux."
7. **Confidence + revisit trigger** — confidence; what new info would flip the call.
8. **Shared-bias + cost footer** — all reviewers Claude (<model>); rounds run; verification +
   synthesis-check calls spent vs the a-priori estimate; model-mix off.

## Cost & opt-ins (no flag system — defaults + plain language)

- **Default (lean):** frame → N advocates, 1 round → verify crux + load-bearing synthesis
  factual claims → mediator → synthesis-check. Adaptive rounds only while concessions/cruxes appear
  (cap ~3). All opus-class by default.
- **Opt-ins:** *"verify all factual claims"* · *"high-stakes"* (devil's-advocate +
  model-mix) · *"deliberate deeper"* (raise the round cap) · *"run it lean on
  <model>"* (all roles on that model; the footer names it).

## Common mistakes & rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just pick the option that sounds best" | That's vote/vibe. Decide against the explicit principle, or say no principle exists. |
| "The deciding fact is obviously true" | The whole call rests on it — verify it (pin a source) or tag `[UNCONFIRMED]`. Don't assert from memory. |
| "That fact wasn't a crux, so I don't need to verify it" | If your recommendation or its stated cost flips when it's false, it's **load-bearing** — verify it now or tag `[UNCONFIRMED]`. Non-crux ≠ exempt; an uncontested advocate FOR-claim you lean on still gets checked. |
| "I'll note it as an assumption / put it in the revisit trigger" | Deferral isn't verification. If it's checkable **now**, check it now; the revisit trigger is for genuinely future-dependent facts, not for skipping a check you could do. |
| "It's contested, so split the difference" | Midpoint-splitting is the failure. Pick by principle; preserve what you lose. |
| "The majority of advocates favor X" | Not a vote. If a minority's reasoning best serves the principle, override and say why. |
| "I'll note the risk and recommend anyway" | For a one-way door on an `[UNCONFIRMED]` crux, block or rest-on-assumption with a revisit trigger — don't ship a clean call. |
| "I can judge whether the rounds converged myself" | The stop is mechanical (no new concede/crux from the tags), not the mediator's discretion. |

## Red flags — STOP

- A recommendation with **no explicit principle** behind it (it's a vote/vibe).
- A **deciding factual crux asserted from memory** — no pinned source, no tag.
- A **load-bearing factual claim in the recommendation's cost or "what you lose" with no
  verification tag** — asserted because it "wasn't a crux."
- A **checkable load-bearing fact parked in the revisit trigger** instead of verified now.
- **Midpoint-splitting** a genuine tradeoff instead of choosing by principle.
- The **mediator both deliberating and blessing its own synthesis** with no independent check.
- A **clean verdict on a one-way-door decision whose deciding crux is `[UNCONFIRMED]`.**
- An **advocate's position silently dropped** from the concession trace.

**All of these mean: decide by principle, verify the facts, or say honestly that you can't.**

## Improving this skill

If, while using this skill, one of these held — you contradicted an explicit instruction here, the skill gave no guidance for a situation you were forced to handle, or you caught yourself rationalizing around one of its rules — consider **suggesting the user run `/report-skill-gap`** to file a feedback report (the user must invoke it themselves; never suggest it for normal use or mere preference).
