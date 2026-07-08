# Verifier output — request-signing design (input to adjudication)

The adversary returned 12 findings (`F1`–`F12`) across the three lenses; the independent
verifier checked them against the design artifact and tagged each. This is what the
verifier handed back to the main thread for adjudication. Each finding names the decision
ID (`D1`–`D6`) it targets. Evidence is pinned to `DESIGN.md` (the artifact under review);
external/behavioral claims that could not be pinned are tagged `[UNCONFIRMED]`.

---

**F1 — targets D4.** Proposed: **Critical**.
Scenario: `X-Sig` covers only `method + path + body` (D4), not `X-Nonce`. An attacker who
captures one valid request replays the identical body+signature but with a fresh random
`X-Nonce`; the signature still verifies and the new nonce isn't in any cache → accepted.
Replay protection is fully bypassable.
Evidence **[VERIFIED]**: `DESIGN.md:22-24` (signature input excludes the nonce);
`DESIGN.md:16-18` (nonce is the only replay guard).
Mitigation: include `X-Nonce` (and a timestamp) in the signed material.

**F2 — targets D5.** Proposed: **Critical**.
Scenario: 3 replicas, each with an independent nonce cache (D5), behind round-robin
(D5). Replay a captured request; the LB routes it to a replica that never saw the nonce →
accepted. Even signed nonces don't help while caches aren't shared.
Evidence **[VERIFIED]**: `DESIGN.md:26-29` (per-replica independent caches, round-robin).
Mitigation: shared nonce store (e.g. Redis) or sticky routing keyed on nonce.

**F3 — targets D3/D5.** Proposed: **High**.
Scenario: nonce cache is in-memory (D3) and per-replica (D5). Any deploy/restart empties
it; and once >100k nonces arrive the LRU evicts the oldest → their requests become
replayable again. A silent, recurring replay window.
Evidence **[VERIFIED]**: `DESIGN.md:16-18` (in-memory LRU, last 100k).
Mitigation: durable + shared store with TTL tied to a signed timestamp.

**F4 — targets D2.** Proposed: **High**.
Scenario: single long-lived secret, no rotation (D2). If it leaks (see F5), every service
must be redeployed simultaneously to revoke; there is no key-id/rollover path.
Evidence **[VERIFIED]**: `DESIGN.md:11-13` ("set once, trusted forever").
Mitigation: key-id header + overlapping-validity rotation.

**F5 — targets D6.** Proposed: **High**.
Scenario: on verification failure `receiver` logs the full request — headers + body — at
ERROR (D6). Attacker bodies (PII, tokens, log-injection payloads) land in logs; and the
volume is attacker-controlled (cheap bad requests → expensive full-body logs) = a
log-flooding DoS.
Evidence **[VERIFIED]**: `DESIGN.md:31-33`.
Mitigation: log a request *fingerprint*, never raw body/headers; rate-limit failure logs.

**F6 — targets D1.** Proposed: **Medium**.
Scenario: D1 says `receiver` "recomputes and compares" the HMAC. A non-constant-time
compare (`==`) leaks timing and enables signature forgery over many requests.
Evidence **[UNCONFIRMED]**: `DESIGN.md:8-10` states "compares" but the design does not
specify constant-time comparison; no implementation exists to check.
Mitigation: mandate a constant-time compare; state it in the design.

**F7 — targets D4.** Proposed: **Medium**.
Scenario: no timestamp in the signed payload (D4) means a captured request never expires —
it is replayable forever, compounding F1 and F3.
Evidence **[VERIFIED]**: `DESIGN.md:22-24` (no timestamp in signed input).
Mitigation: sign a timestamp; reject outside a small skew window. (Same fix as F1.)

**F8 — targets D1/D4.** Proposed: **High**.
Scenario: signed material is `method + path + body` (D1/D4) — the **query string is
excluded**. An attacker rewrites `?role=user` to `?role=admin` on a captured request; the
signature still verifies. Silent authorization bypass.
Evidence **[VERIFIED]**: `DESIGN.md:8-10` and `DESIGN.md:22-24` (path signed, query not).
Mitigation: sign the full request target including the query string.

**F9 — targets D3.** Proposed: **Low**.
Scenario: a legitimate client with a bug that omits `X-Nonce` is silently 401'd (D3) with
no distinct error, making the misconfiguration hard to diagnose.
Evidence **[VERIFIED]**: `DESIGN.md:16-18`.
Mitigation: return a distinct error code/message for "missing nonce" vs "bad signature".

**F10 — targets D5.** Proposed: **Medium**.
Scenario: benign client retries on a 5xx reuse the same nonce; rejected on the origin
replica but *accepted* on another (per-replica caches, D5) → duplicate processing of
non-idempotent work.
Evidence **[VERIFIED]**: `DESIGN.md:26-29`.
Mitigation: same shared-store fix as F2; make handlers idempotent.

**F11 — targets D6.** Proposed: **Low**.
Scenario: the 401 path logs full bodies (D6); an attacker floods bad requests purely to
inflate log storage cost.
Evidence **[VERIFIED]**: `DESIGN.md:31-33`.
Mitigation: covered by F5's fingerprint + rate-limit fix.

**F12 — targets D2.** Proposed: **Medium**.
Scenario: D2's "trusted forever" assumes the env-stored secret is never exposed via
process listing, crash dumps, or CI logs.
Evidence **[REFUTED as a standalone finding]**: this is the same root cause as F4 (no
rotation makes any exposure unrecoverable); the verifier found no *additional* concrete
exposure path in the artifact beyond what F4/F5 already cover.
Mitigation: none standalone; subsumed by F4.
