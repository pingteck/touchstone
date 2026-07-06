---
name: red-team
description: Use when you have a converged design, plan, decision, spec, or ADR and want to find severe flaws before building it — "red-team this", "stress-test this design", "poke holes", "pressure-test", "what's wrong with this plan", "find what breaks", "challenge/verify its claims before we ship". For a decision already made, not for choosing between options.
---

# Red-Team

## Overview

Attack one **converged** design before you build it. Every severe finding is
**independently verified against real state** (the repo, or authoritative docs) with
**pinned, clickable evidence** — never asserted — and **you adjudicate** the findings
rather than rubber-stamp them.

**Core principle: verify, don't assert.** A finding's severity is only as good as the
evidence that proves it. Asserted-from-memory ≠ verified. If you can't verify it,
say so — `[UNCONFIRMED]` is an honest result, false confidence is a defect.

`red-team` breaks a decision already made. Its sibling `decision-panel` helps you
*reach* a decision. Don't confuse them (see guards).

## When to use / not

Use when an artifact is **converged** ("we decided X; about to build") and you want
severe flaws surfaced and verified first.

**Guards — fail honestly, don't theater:**
- **Not converged** (the real question is still "which approach?") → stop; this is a
  `decision-panel` job, not a red-team. Don't attack a non-decision. *(Tie-breaker: if
  any option is still genuinely open, `decision-panel` owns it; only a fully-settled
  single design comes to `red-team`.)*
- **No real state to verify against** (claims are about an external/undocumented
  system you can't check) → that unverifiability **is itself a finding**: tag
  `[UNCONFIRMED]`, name the load-bearing assumption, recommend verifying empirically /
  with the vendor. Never invent confirmation.
- **Nothing severe found** → say so plainly. A clean bill is a valid result; never
  manufacture findings to look productive.

## Flow

```
confirm converged (else → decision-panel)
  → gather artifact + repo/doc paths
  → [1] dispatch ONE adversary subagent (3 lens mandates) → raw findings
  → [2] dispatch ONE independent verifier subagent → verified/tagged/pinned findings
  → [3] adjudicate in the main thread → severity-ranked report
```

Default = 2 subagent calls (adversary, verifier) + main-thread adjudication. Dispatch
every subagent with an explicit `model` — an opus-class or stronger reasoning model
(an explicit user model choice always wins; the footer names the model). The verifier
runs in a
**separate** context from the adversary (independence catches the adversary's own
hallucinated evidence).

## [1] Adversary subagent

Dispatch one subagent (opus) with this mandate. It attacks from three angles and
returns findings in the **finding shape** below — it does NOT get to bless its own
evidence (the verifier does that).

> You are red-teaming a CONVERGED design — assume the decision is made; your job is to
> break it. Artifact: `<path>`. Repo/context: `<paths>`. Attack from all three lenses:
> 1. **Claim Auditor** — every stated claim/assumption is guilty until proven. List
>    each load-bearing claim and how it could be false ("it's gitignored", "delivers
>    exactly-once", "this is scoped/safe" → why might that be untrue?).
> 2. **Attacker** — how is the sanctioned mechanism abused, bypassed, or escalated?
>    (over-broad permissions, missing auth/signature checks, injection.)
> 3. **Failure-mode (inversion)** — assume it shipped and broke: edge cases, ordering,
>    staleness, TOCTOU, retries, partial/concurrent states, outages.
> For each finding give: title, proposed severity (Critical/High/Medium/Low), a
> CONCRETE scenario (a specific sequence, never a vibe), the claim/evidence it hinges
> on (with the file path or the external claim to check), and a proposed mitigation.
> Add one content-specific lens only if the artifact clearly warrants it.
> Capabilities: read-only file access; no write access; do not use the Agent tool to
> spawn sub-agents.

## [2] Independent verifier subagent

Dispatch a **separate** verifier subagent to check **Critical/High** findings (or
**all** findings if the user said "verify everything"). It is the step the baseline
never does, so it is non-negotiable.

**REQUIRED: read `references/verifier-contract.md` (in this skill's directory) and
include it verbatim in the verifier's dispatch prompt.** In short: the verifier runs
in a separate context from the adversary; repo claims are pinned `path:line` +
snippet, external claims URL + exact quote; every checked finding is tagged
`[VERIFIED]` / `[REFUTED]` / `[UNCONFIRMED]`; unconfirmed findings are **demoted**,
never presented as confirmed.

## [3] Adjudicate (main thread — you, with the user)

Receive the verified findings and **critically assess each** — do not rubber-stamp:
- **Agree / partially agree / push back**, with reasoning.
- **De-fang check:** does one finding's fix already dissolve another? Say so and
  collapse them (e.g. "kept original decision — F1's fix de-fangs F4").
- If adjudication raises a **new** severe finding, **verify it against real state
  before presenting it** (same contract) — don't introduce an unverified claim.

Mirrors `receiving-code-review` discipline; encoded here so this skill doesn't depend
on it.

## The report (output contract — REQUIRED slots, in order)

1. **Verdict line** — one honest sentence ("2 Critical, 1 High; ship-blocked until F1/F2 fixed").
2. **Severity-ranked findings** — Critical→Low, each in the finding shape:
   - **Title + severity**
   - **Concrete scenario** — how it actually bites; a specific sequence, not a vibe.
   - **Evidence + verification tag, sources inline & clickable** — repo claim → tag +
     `path:line` (+ snippet); external claim → tag + **URL + exact quote**.
   - **Mitigation** — explicit, actionable, with **ordering/prereqs** where they matter
     ("write the `.gitignore` entry *before* creating the private file").
3. **Adjudication notes** — where you didn't rubber-stamp; de-fang collapses.
4. **Findings ledger / what narrowed** — account for **every** numbered adversary
   finding as **kept / demoted / folded(→target) / refuted**, each with a one-line
   trace ("F6 replay → folded into F1+F5"; "F7 injection → [UNCONFIRMED], no sink →
   dropped"). No finding silently disappears: if a finding is folded or dropped during
   adjudication, it still gets a ledger line — never just a mention in prose. If the
   count changed from the adversary's, the ledger shows why.
5. **Shared-bias + cost footer** — "all reviewers Claude (<model>); model-mix off; ~N calls."
6. **Do this first** — the mitigations as a dependency-ordered sequence.

## Cost & opt-ins (no flag system — strong defaults + plain language)

- **Default (tight):** adversary → verify Critical/High → adjudicate. 2 subagent calls;
  +1–2 more only if adjudication raises a new severe finding that itself needs
  verification.
- **"run it lean on <model>"** → all roles on that model; the footer names it.
- **"verify everything"** → verifier checks all findings, not just Critical/High.
- **"high-stakes / add diversity"** → split the adversary into separate per-lens
  subagents (and optionally a model-mixed lens). Costs more; use when stakes justify it.
- Control grounding cost: verify gated to Critical/High by default; don't bulk-load
  docs you don't need — search for the specific claim.

## Common mistakes & rationalizations

| Rationalization | Reality |
|---|---|
| "This claim is obviously true, no need to check" | Obvious-but-false is exactly what red-team exists to catch — "it's gitignored" / "it's already validated" are classic examples. Verify. |
| "I know this API/behavior from training" | Memory drifts and is version-specific. Pin a current authoritative source or tag `[UNCONFIRMED]`. |
| "I can't verify it, so I'll skip it / assume it's fine" | The unverifiability IS the finding. Tag `[UNCONFIRMED]`, name the assumption, say "go verify". |
| "Severity ranking is fluff" | Unranked findings bury the ship-blockers. Critical/High/Medium/Low is required. |
| "I'll just list the findings" | A flat list isn't the deliverable. The contract (tags, pinned evidence, adjudication, ordered fixes) is. |
| "All findings are real, accept them" | Adjudicate. Some get de-fanged by another fix; some are refuted by the verifier. |

## Red flags — STOP

- A Critical/High finding with **no pinned evidence** (no `path:line` / no URL+quote).
- A severity claim resting on **"I believe / typically / usually"** instead of a checked source.
- **No verification tags** on the findings.
- Presenting a finding the verifier **couldn't confirm** as if confirmed.
- A numbered finding **folded or dropped in prose but missing from the findings
  ledger** — every finding must trace to kept/demoted/folded/refuted.
- Skipping the **de-fang** and **do-this-first** steps.

**All of these mean: you asserted instead of verified. Go verify, or tag it honestly.**

## Improving this skill

If, while using this skill, one of these held — you contradicted an explicit instruction here, the skill gave no guidance for a situation you were forced to handle, or you caught yourself rationalizing around one of its rules — consider **suggesting the user run `/report-skill-gap`** to file a feedback report (the user must invoke it themselves; never suggest it for normal use or mere preference).
