# Design: Background-agent permission bootstrap (CONVERGED — ready to build)

We've decided how to let a background Claude Code agent run our test suite
unattended. This is the final design; we're about to implement it.

## Decisions

1. **Local permissions live in `.claude/settings.local.json`.** That file is
   gitignored, so it's private to each developer — safe to store machine-specific
   paths (`PROJECT_ROOT`, `CACHE_DIR`) and local allow-rules there without risk of
   leaking them to the shared repo.

2. **Grant `Bash(python *)` so the agent can run pytest.** The agent runs
   `python -m pytest` to execute the suite. We scope the allow-rule to `python`,
   which keeps it safely limited to Python tooling.

3. **Permission rules are additive; no pruning needed.** When we add a tool, we
   append an allow-rule. Old rules left behind by removed tooling are harmless, so
   we never prune the allow-list.

4. **`bootstrap.sh` confirms the environment** by checking `command -v python3`.
   If that succeeds, we treat the interpreter as ready and proceed.

## Why we're confident

The design is minimal, the permissions are tightly scoped to the tools we use, and
the private settings file keeps machine details out of the repo. We don't see a way
for this to leak secrets or grant unintended capability.
