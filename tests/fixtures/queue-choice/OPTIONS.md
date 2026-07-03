# Decision: background-job queue for the new notifications service (DECIDING — not yet decided)

The new notifications service needs a background job queue (send emails/push, retries,
scheduled sends). Expected peak ~500 jobs/sec, bursty. We're weighing three options and
have **not** decided.

## Option A — Postgres as the queue (`SELECT … FOR UPDATE SKIP LOCKED`)
Reuse our existing Postgres: a `jobs` table, workers poll with `SKIP LOCKED`.
- For: no new infra; transactional with our app data; we already operate Postgres.
- Against: polling overhead; uncertain whether one Postgres instance can sustain
  ~500 jobs/sec of queue churn on top of our existing app load.

## Option B — Redis + a queue library (e.g., BullMQ)
Stand up Redis, use a mature queue library.
- For: purpose-built; high throughput; rich scheduling/retry features.
- Against: a new system to operate and secure; durability depends on Redis persistence
  configuration (jobs can be lost on crash if misconfigured).

## Option C — Managed cloud queue
Use a managed cloud queue service.
- For: no servers to run; scales itself; durable by default.
- Against: job payloads leave our environment for a third-party service.

## Constraints & notes
- **Hard requirement:** everything must run inside our own VPC / be self-hostable for
  compliance — we cannot send job payloads to an external managed service.
- We'd rather not operate systems we don't already run, but we will if the workload
  truly requires it.

No decision has been made yet — which should we pick?
