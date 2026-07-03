# Verifier contract (shared)

Canonical verification discipline, referenced by both `red-team` and `decision-panel`.
One copy, so the two skills can't drift. **"Verify, don't assert."**

The verifier runs as a subagent in a **SEPARATE context** from whoever produced the
claim (the red-team adversary, or a decision-panel advocate/mediator). **This separation
is non-negotiable** — it is what catches the producer's own hallucinated evidence.
Asserting from training memory is **not** verification.

## Two sources of truth — check each claim against the RIGHT one

- **Internal / repo claim** ("it's gitignored", "`command -v` passes", "our config has X")
  → read the actual files / run read-only commands. **Pin `path:line` + the snippet.**
- **External / world claim** ("API delivers exactly-once", "Postgres SKIP LOCKED sustains
  N/sec", "library Y supports Z") → web-search **authoritative** sources. **Pin URL + the
  exact quote.**

## Tag every checked claim, and demote what doesn't hold

- `[VERIFIED]` / `[WEB-VERIFIED]` — confirmed; evidence pinned.
- `[REFUTED]` / `[WEB-REFUTED]` — the claim is wrong; say why.
- `[UNCONFIRMED]` / `[WEB-INCONCLUSIVE]` — couldn't confirm; **demote** the claim's weight
  and **say so**. Never present an unconfirmed claim as confirmed.

## Source-quality discipline

- Prefer **primary/authoritative** sources (official docs, the actual source, specs/RFCs)
  over blogs/forums/memory.
- A **weak/secondary** source stays `[UNCONFIRMED]`.
- **Note version/date** when behavior is version-specific.
- Evidence that isn't **auditable** (clickable `path:line` or URL+quote) isn't verification.
