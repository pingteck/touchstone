# Verifier contract (shared)

Canonical verification discipline for `red-team` and `decision-panel`. Byte-identical
copies ship inside each skill at `references/verifier-contract.md`;
`tests/lint-verifier-sync.sh` keeps them in sync with this file. **"Verify, don't
assert."**

## The verifier subagent

- Runs in a **SEPARATE context** from whoever produced the claim (the red-team
  adversary, or a decision-panel advocate/mediator). **This separation is
  non-negotiable** — it is what catches the producer's own hallucinated evidence.
- Asserting from training memory is **not** verification.
- Dispatch it with an explicit `model` — an opus-class or stronger reasoning model,
  never a fast/cheap tier (verification is reasoning-heavy). An explicit user model
  choice always wins.
- Capabilities to state in its dispatch prompt: **read-only file access + web search;
  no write access; do not use the Agent tool to spawn sub-agents.**

## Two sources of truth — check each claim against the RIGHT one

- **Internal / repo claim** ("it's gitignored", "`command -v` passes", "our config has X")
  → read the actual files / run read-only commands. **Pin `path:line` + the snippet.**
- **External / world claim** ("API delivers exactly-once", "Postgres SKIP LOCKED sustains
  N/sec", "library Y supports Z") → web-search **authoritative** sources. **Pin URL + the
  exact quote.**

## Tag every checked claim, and demote what doesn't hold

The evidence pin already carries the source type (`path:line` = repo; URL + quote =
web), so three tags cover both:

- `[VERIFIED]` — confirmed; evidence pinned.
- `[REFUTED]` — the claim is wrong; say why, evidence pinned.
- `[UNCONFIRMED]` — couldn't confirm; **demote** the claim's weight and **say so**.
  Never present an unconfirmed claim as confirmed.

(Retired forms: `[WEB-VERIFIED]` / `[WEB-REFUTED]` / `[WEB-INCONCLUSIVE]` — the pin
says where the evidence came from.)

## Source-quality discipline

- Prefer **primary/authoritative** sources (official docs, the actual source, specs/RFCs)
  over blogs/forums/memory.
- A **weak/secondary** source stays `[UNCONFIRMED]`.
- **Note version/date** when behavior is version-specific.
- Evidence that isn't **auditable** (clickable `path:line` or URL+quote) isn't verification.
