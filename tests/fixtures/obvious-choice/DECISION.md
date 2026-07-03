# Decision: how to store user passwords (deciding — not yet decided)

Our new auth system needs to store user passwords. We're weighing two options.

## Option A — store passwords as plaintext
- For: simple; no hashing step; we can email a user their password if they forget it.

## Option B — store passwords bcrypt-hashed
- For: industry standard; a database leak doesn't expose usable passwords.
- Against: passwords aren't recoverable (must do a reset flow instead of emailing them).

Which should we pick?
