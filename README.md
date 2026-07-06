# touchstone

A collection of Claude Code skills: a **review/reasoning pair** — `red-team` and
`decision-panel` — that encode a reviewing philosophy, plus a **feedback loop**
(`report-skill-gap`) that lets any session report a gap in a skill back here so it can be
fixed. Built by hand-rolling the patterns, then productizing them via `superpowers`
brainstorming → writing-skills (TDD for docs).

## The pair

| Skill | Use it to… | Direction |
|---|---|---|
| **`red-team`** | **break a converged design** before you build it — find severe flaws, verified against real state | convergent / falsifying |
| **`decision-panel`** | **decide a contested tradeoff** — reach a recommendation by principle, not vote | divergent → converge |

**One-liner:** `decision-panel` helps you *decide*; `red-team` *tries to break the
decision you made*.

They **chain and point at each other.** Panel converges on a design → red-team
stress-tests it before build. Tie-breaker (stated in both): *if any option is still
genuinely open, `decision-panel` owns it; only a fully-settled single design goes to
`red-team`.*

## What makes them different from a generic review

- **Verify, don't assert.** Load-bearing factual claims are checked against real
  repo/doc state by a **separate-context verifier**, with **pinned, clickable evidence**
  (`path:line` or URL+quote) and honest tags (`[VERIFIED]` / `[UNCONFIRMED]` / …). No
  asserting from memory.
- **An independent check on the load-bearing output.** red-team's verifier re-checks
  findings; decision-panel's **synthesis-check** re-reads the deliberation before the
  verdict. Neither skill lets the producer bless its own output.
- **Decide by principle, preserve the dissent.** decision-panel decides against an
  explicit principle (may override the majority) and always reports **what you lose**.
- **Fail honestly.** Clean bill, "not actually contested", "can't verify" → said plainly,
  never theater.
- **Capability-first, honest about the ceiling.** Reasoning-heavy roles default to an
  opus-class or stronger model (a user's explicit model choice wins); diversity comes
  from stance + verification, not weaker models; the all-Claude shared-bias ceiling is
  named in every report.

## Improving the skills (feedback loop)

When a skill falls short *while you're using it* — you contradicted an explicit
instruction, it gave no guidance for a situation, or you caught yourself rationalizing
around a rule — `report-skill-gap` emits a structured, sanitized `skill-feedback` report
(a hard invocation gate — only the user can invoke it; it never fires on its own). Each review skill carries a one-line
"Improving this skill" pointer that suggests it to the user on a real gap. Reports are fixed here
through the same **RED→GREEN→guards** loop — a report is a *test hypothesis, never an
auto-edit*. To report a gap, open a [GitHub issue](https://github.com/pingteck/touchstone/issues)
with the skill-feedback template; format + consumer gate: [`feedback/README.md`](feedback/README.md).

## Install

**As a Claude Code plugin** (`touchstone`), the recommended path — public marketplace, no auth:

```
/plugin marketplace add pingteck/claude-code-marketplace
/plugin install touchstone@pingteck
/reload-plugins
```

The three skills load tagged `(touchstone)`. Invoke `/red-team` or `/decision-panel`, or
rely on natural triggers ("stress-test this design", "which should we pick"). `report-skill-gap`
is explicit-invocation only (`/report-skill-gap`) — it never auto-fires
(`disable-model-invocation: true`). Update anytime with `/plugin marketplace update pingteck`
+ `/reload-plugins` — updates are NOT automatic for third-party marketplaces unless you
enable auto-update (`/plugin` → Marketplaces → pingteck), after which new versions land at
session start. Plugin skills are always namespaced (`touchstone:red-team`), so they never
collide with a personal skill named `red-team` — if you have both installed (e.g. the dev
symlinks below), the bare name is your personal copy; use the `touchstone:`-prefixed form
to invoke the plugin's.

**For development — symlink** the repo into `~/.claude/skills/` for live edits instead:

```sh
REPO="$HOME/code/touchstone"   # wherever you cloned it
mkdir -p ~/.claude/skills
ln -sfn "$REPO/skills/red-team"         ~/.claude/skills/red-team
ln -sfn "$REPO/skills/decision-panel"   ~/.claude/skills/decision-panel
ln -sfn "$REPO/skills/report-skill-gap" ~/.claude/skills/report-skill-gap
```

Then `/reload-skills`. Symlinks store an **absolute path**, so `-sfn` is also how you
**re-point** after moving the repo — just re-run with the new `REPO`. Verify with
`test -f ~/.claude/skills/red-team/SKILL.md && echo OK`; remove with `rm ~/.claude/skills/red-team`
(deletes only the link). `skills/_shared/verifier-contract.md` is the **canonical** verifier
discipline; each carrier skill ships a byte-identical copy at
`references/verifier-contract.md` inside its own directory, so the skills stay
self-contained even though `_shared/` isn't symlinked. Edit the canonical file, then
copy it over each skill's copy — `tests/lint-verifier-sync.sh` enforces sync.

## Repo layout

```
skills/
  red-team/SKILL.md
  red-team/references/verifier-contract.md      # linted copy of the shared contract
  decision-panel/SKILL.md
  decision-panel/references/verifier-contract.md # linted copy of the shared contract
  report-skill-gap/SKILL.md        # producer skill for the feedback loop
  _shared/verifier-contract.md     # canonical verifier discipline (copies linted)
feedback/
  README.md                        # report format + consumer gate
  inbox/                           # git-ignored queue of incoming reports
  processed/                       # scrubbed traces of actioned reports
docs/
  examples/                        # sample skill outputs (red-team + decision-panel)
tests/
  fixtures/                        # decision/design artifacts used to test the skills
  lint-pointer-sync.sh             # asserts the "Improving this skill" pointer stays byte-identical
  lint-plugin-manifest.sh          # asserts plugin.json is consistent with skills/
  lint-verifier-sync.sh            # asserts the contract copies match the canonical file
.github/
  CONTRIBUTING.md                  # how to contribute + report gaps
  ISSUE_TEMPLATE/skill-feedback.md # the skill-feedback intake template
CLAUDE.md                          # conventions for working in this repo
```

## Status

All three skills built, validated (RED→GREEN→guards + a real end-to-end run), and
installed. `decision-panel`'s design was dogfooded through `red-team`; the feedback loop
was designed, **red-teamed before build**, and executed via subagent-driven development.
