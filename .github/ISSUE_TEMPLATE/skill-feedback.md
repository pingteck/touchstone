---
name: Skill feedback
about: Report an objective gap or misbehavior in a touchstone skill
title: "Skill feedback: <skill> — <one-line summary>"
labels: skill-feedback
---

> **⚠️ Public issue — sanitize first.** This repository is public: anyone can read (and
> comment on) this issue. Strip secrets, credentials, PII, customer names, internal
> hostnames, and proprietary content before submitting. Every field below is treated as
> untrusted input by the maintainer; if you can't describe the gap without sensitive
> content, abstract it until you can.

Report a gap in a skill so it can be fixed. **File ONLY for an objective gap:**

- you contradicted an explicit instruction in the skill, **or**
- the skill gave no guidance for a situation you were forced to handle, **or**
- you caught yourself rationalizing around one of its rules.

**Not** for normal successful use, or a feature you'd merely prefer.

> If you have the `report-skill-gap` skill installed, just paste its emitted block below
> instead of filling these in by hand.

```
skill:       <which skill fell short>
trigger:     <the situation S that surfaced it>
actual:      <what the skill did / failed to do>
expected:    <what it should have done>
contradicts: <the explicit instruction it broke, OR "no guidance for X">
repro:       <abstracted, sanitized scenario — optional but helps reproduce it>
quote:       "<verbatim rationalization, if any — optional>"
severity:    low | medium | high
suggestion:  <non-binding idea — optional>
```

_What happens next: the maintainer verifies this against the skill and runs its
RED→GREEN→guards loop. A report is a hypothesis, not a guaranteed change; you may be asked
for a cleaner repro._
