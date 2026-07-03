# Team & engineering context

We're a 3-engineer team running a small SaaS. We operate everything ourselves — no
dedicated ops/SRE. Our stated engineering principle, applied consistently in past
decisions: **prefer the smallest operational surface area — reuse infrastructure we
already run and understand over adopting new systems, unless the new system is clearly
necessary.**

Today we run: PostgreSQL (self-managed) and a few app servers. We have **no** Redis, no
message broker, and no managed cloud queue.
