# Benchmark boundary

The cost chart and current benchmark rows use a fresh, two-scenario maintainer
capture from **2026-09-17**, produced with Tokki **1.0.63**. Older session and
failure-log rows in the README retain their original dates.

The [aggregate receipt](docs/evidence/token-cost-snapshot-2026-09-17.json)
records 11,989 baseline tokens and 1,736 compact Tokki tokens (6.9x). Scoped
agent policy contributes 4,796 → 352 tokens; repository context contributes
7,193 → 1,384. Both failure-log scenarios were unavailable in this capture and
are excluded from its totals. The source inputs remain private: the receipt
supports checking the arithmetic, not reproducing the underlying workload.
These figures must not be read as a universal saving or as billing evidence.

The chart normalizes the measured ratio to **1 million baseline input tokens**
and approximately **0.145 million Tokki tokens**. This is a projection, not a
measured million-token workload. Tokens are assumed to accumulate across
requests with at most 272,000 input tokens each, so standard rates apply;
single long-context requests may use different rates.

`Grade A` means an exact count for the tokenizer used in the capture. The
2026-09-17 capture used the `gpt-4o` tokenizer. Applying those counts to GPT-6
Astra or GPT-5.6 input prices is a cost approximation, not native model token
accounting or an exact provider bill. Prices and the ECB exchange rate
(1.1481 USD per EUR) were checked on 2026-09-17; sources are in the receipt.
Output tokens, caching, tools, retries, latency, task success and Codex
subscription quotas are excluded. The workload differs from July, so the
ratio change is not a like-for-like measurement of product improvement.

Future comparative claims require a synthetic, publishable suite with raw JSON
results, fixed model/tokenizer/parameters/prices, input and output tokens,
latency, retry count, task-success rate, and an explicit privacy review. The
primary comparison is total cost at equivalent task success, not tokens removed.
