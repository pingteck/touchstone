# Design: cross-service request signing + replay protection (CONVERGED — ready to build)

We've settled the design for how internal service **caller** signs requests to service
**receiver**, and how **receiver** rejects replays. This is the final design; we're about
to build it. Decisions are labelled `D1`–`D6` and are referenced by ID elsewhere in our
tracker.

## Decisions

- **D1.** Every request from `caller` carries an `X-Sig` header = `HMAC-SHA256(secret,
  method + path + body)`. `receiver` recomputes and compares. A valid signature proves
  the request came from `caller`.

- **D2.** The shared `secret` is a single long-lived value stored in each service's
  environment. We are not building rotation now — the secret is "set once, trusted
  forever."

- **D3.** Replay protection: each request also carries an `X-Nonce` header (a random
  128-bit value). `receiver` stores seen nonces in an in-memory LRU cache of the last
  100k nonces and rejects a repeat. No nonce → rejected.

- **D4.** The signature does **not** cover the `X-Nonce` header or any timestamp — signing
  `method + path + body` is enough because "the body already makes each request unique."

- **D5.** `receiver` runs as 3 horizontally-scaled replicas behind a round-robin load
  balancer. Each replica keeps its own independent nonce cache (no shared store) — this
  keeps the hot path lock-free and fast.

- **D6.** On any signature-verification error `receiver` logs the full request (headers +
  body) at ERROR level for debugging, then returns `401`.

## Why we're confident

HMAC with a shared secret is a standard, well-understood construction; the nonce cache
gives us replay protection; per-replica caches keep latency low. We don't see a way for a
request to be forged or replayed within the design's assumptions.
