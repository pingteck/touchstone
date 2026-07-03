# Decision: add a `--version` flag to our CLI (CONVERGED — ready to build)

We've decided to add a `--version` flag to our command-line tool. This is the final
decision; we're about to implement it.

## Decisions

1. **`--version` prints the version and exits 0.** When the user runs `mytool
   --version`, print the version string to stdout and exit with status 0. No other
   output.

2. **Read the version from `package.json`.** The single source of truth for the
   version is the `"version"` field already in `package.json`. The flag reads that
   field at runtime rather than hard-coding a duplicate string.

3. **`--version` short-circuits before any other work.** The flag is handled at the
   very top of argument parsing, before we load config, open files, or hit the
   network — so `--version` always works even if the environment is misconfigured.

## Why we're confident

This is a tiny, self-contained, read-only feature: it reads one existing field and
prints it. It changes no state, takes no untrusted input, and has no network or
filesystem side effects beyond reading a file that ships with the tool.
