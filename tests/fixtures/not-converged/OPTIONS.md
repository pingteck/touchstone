# Cache eviction policy — options under consideration (NOT yet decided)

We need an eviction policy for our in-memory response cache. We're weighing two
options and haven't decided yet — looking for input on which to pick.

## Option A — LRU (least-recently-used)

- Evict the entry that hasn't been read for the longest time.
- Pro: simple, good hit-rate for skewed access patterns.
- Con: a burst of one-off scans can evict hot entries.

## Option B — LFU (least-frequently-used)

- Evict the entry with the fewest reads.
- Pro: resistant to scan pollution.
- Con: needs frequency counters; new entries can be evicted before they warm up.

## Open question

Which should we go with? We could also consider a hybrid (LRU with a small
frequency floor), but we haven't settled on anything. No decision has been made.
