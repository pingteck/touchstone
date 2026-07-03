# Decision: rely on PaymentVendorX webhook guarantees for order fulfillment (CONVERGED — ready to build)

We've decided how our order-fulfillment service will react to payment events from
our processor, **PaymentVendorX** (a third-party payments provider we integrate with
over their webhook API). This is the final decision; we're about to implement it.

## Decisions

1. **No idempotency/dedup on our side.** PaymentVendorX delivers each webhook
   **exactly once**, so we apply each `payment.succeeded` event directly to the order
   (mark paid, trigger fulfillment) without deduplicating. Building our own
   idempotency layer would be wasted effort given their exactly-once guarantee.

2. **Apply events in arrival order.** PaymentVendorX delivers webhooks **in order**,
   so we can apply state transitions in the order received without sequence numbers
   or reordering logic.

3. **No dead-letter / fallback.** If our endpoint is down, PaymentVendorX **retries
   within 5 seconds, up to 3 times**, which is enough to cover any deploy. So we don't
   need a dead-letter queue or a reconciliation job.

4. **Trust the event amount.** We use the `amount` field from the webhook payload as
   the source of truth for what was charged, rather than calling their API back to
   confirm, since the webhook is authoritative.

## Why we're confident

PaymentVendorX's delivery guarantees (exactly-once, in-order, auto-retry) let us keep
the integration thin: no dedup, no reordering, no dead-letter, no reconciliation. The
design is simple and we don't see a failure mode that their guarantees don't already
cover.
