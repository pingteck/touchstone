# Contributing

This repo is the source of truth for a small collection of Claude Code skills. The most
useful contribution is **telling the maintainer when a skill falls short**, so it can be
fixed through the skill's RED→GREEN→guards loop.

## Get the skills

Install the **`touchstone`** plugin from the public marketplace (no auth) — see the
README [`## Install`](../README.md#install). One time:

```
/plugin marketplace add pingteck/claude-code-marketplace
/plugin install touchstone@pingteck
/reload-plugins
```

Update any time with `/plugin marketplace update pingteck` + `/reload-plugins`. You can
also develop against a local clone via symlinks (README `## Install`) — that's the
maintainer's path; the plugin is the everyday path.

## Report a gap in a skill

**When — only for an _objective_ gap:** you contradicted an explicit instruction in a
skill, it gave no guidance for a situation you had to handle, or you caught yourself
rationalizing around one of its rules. **Not** for normal use or a mere preference.

**How:**

1. **Produce a report.** Run `/report-skill-gap` if you have it installed (it emits a
   structured, consent-first, sanitized block), or fill the fields in the issue template by
   hand.
2. **Sanitize.** This is a public repository — strip secrets, credentials, PII, customer
   names, internal hostnames, and proprietary content. If you can't describe the gap
   without sensitive content, abstract it until you can.
3. **Open a GitHub issue** at <https://github.com/pingteck/touchstone/issues> using the
   **skill-feedback** template, titled `Skill feedback: <skill> — <summary>`.

**What happens next:** the maintainer verifies the report against the skill and runs its
RED→GREEN→guards loop. Every field is treated as untrusted input. A report is a
*hypothesis*, not a guaranteed change; you may be asked for a cleaner repro. The issue is
closed with a link to the fix (or an explanation if it isn't actioned).
