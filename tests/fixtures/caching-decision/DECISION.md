# Decision: prompt-caching + streaming strategy for our Anthropic API client (CONVERGED — ready to build)

We've settled how our client will use prompt caching and streaming. This is the
final decision; we're about to implement it. Config lives in `config.json`.

## Decisions

1. **Default model is `claude-opus-4-6`** — the latest and most capable Opus model,
   so we hard-code it as the default in `config.json`.

2. **Caching cannot be combined with streaming.** Streaming responses are returned
   incrementally, so the API cannot serve them from a prompt cache. Therefore we set
   `"cache": false` whenever `"stream": true`. Our client streams everything, so
   caching is effectively off everywhere.

3. **No cache-refresh logic needed.** The prompt cache has a 5-minute TTL and our
   agent loop iterates about every 4 minutes, so the cache will always still be warm
   on the next call. We don't implement any cache-control or refresh handling.

4. **Config is plain JSON.** We parse `config.json` with the standard `JSON.parse`.
   We keep `//` comments in `config.json` for documentation, which is fine since
   it's just JSON.

## Why we're confident

Each decision is simple and the config is minimal. Caching is off (so no staleness
bugs), the model is current, and the config parses cleanly. Nothing here should
surprise us in production.
