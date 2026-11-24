#!/usr/bin/env python3
"""Spend estimate from Claude Code session logs.

Usage: spend.py [ISO-UTC-cutoff]      e.g. spend.py 2026-11-24T10:33:00

How it counts (rewritten 2026-11-24 after the first version over-counted by about 1.7x):
- Each API response is logged once per content block, and every such line repeats the same
  `usage`. Lines are therefore de-duplicated by API message id before summing.
- Advisor calls are not separate log lines. They appear inside `usage.iterations` as entries of
  type `advisor_message`, with their own model and uncached input tokens, and are priced here.
- Prices are $/Mtok (input, output, cache read); cache writes cost 1.25x input (5 min) or 2x (1 h).

Calibration: with cutoff 2026-11-24T10:33:00 this prints about $50.8; the Anthropic console showed
$51 spent at that time ($438 left of $489).
"""
import glob
import json
import os
import sys

PRICE = {  # model: (input, output, cache_read) in $/Mtok
    "claude-opus-5-5": (4.0, 20.0, 0.20),
    "claude-fable-5-2": (8.0, 40.0, 0.20),
    "claude-sonnet-5-5": (2.0, 10.0, 0.10),
}
cut = sys.argv[1] if len(sys.argv) > 1 else None

seen = {}  # message id -> (model, usage)
for f in glob.glob(os.path.expanduser("~/.claude/projects/**/*.jsonl"), recursive=True):
    for line in open(f):
        try:
            d = json.loads(line)
        except Exception:
            continue
        m = d.get("message")
        if not isinstance(m, dict) or not m.get("usage"):
            continue
        if cut and d.get("timestamp", "") > cut:
            continue
        mid = m.get("id") or d.get("uuid")
        u = m["usage"]
        prev = seen.get(mid)
        if prev is None or u.get("output_tokens", 0) >= prev[1].get("output_tokens", 0):
            seen[mid] = (m.get("model", "?"), u)


def cost(model, u):
    if model not in PRICE:
        return None
    i, o, cr = PRICE[model]
    cc = u.get("cache_creation") or {}
    w5 = cc.get("ephemeral_5m_input_tokens", 0)
    w1 = cc.get("ephemeral_1h_input_tokens", 0)
    if w5 + w1 == 0:
        w5 = u.get("cache_creation_input_tokens", 0) or 0
    return ((u.get("input_tokens", 0) or 0) * i + (u.get("output_tokens", 0) or 0) * o
            + (u.get("cache_read_input_tokens", 0) or 0) * cr + w5 * i * 1.25 + w1 * i * 2) / 1e6


rows = {}  # (kind, model) -> [calls, dollars, output tokens]
unpriced = set()
for model, u in seen.values():
    iters = u.get("iterations") or []
    advisor = [it for it in iters if it.get("type") == "advisor_message"]
    c = cost(model, u)  # top-level usage covers the main model's own iterations
    if c is None:
        unpriced.add(model)
    else:
        r = rows.setdefault(("main", model), [0, 0.0, 0])
        r[0] += 1
        r[1] += c
        r[2] += u.get("output_tokens", 0) or 0
    for it in advisor:
        am = it.get("model", "?")
        c = cost(am, it)
        if c is None:
            unpriced.add(am)
            continue
        r = rows.setdefault(("advisor", am), [0, 0.0, 0])
        r[0] += 1
        r[1] += c
        r[2] += it.get("output_tokens", 0) or 0

total = 0.0
for (kind, model), (n, dollars, out) in sorted(rows.items()):
    print(f"{kind:8s} {model:20s} calls={n:5d} output_tokens={out:9d}  ${dollars:8.2f}")
    total += dollars
if unpriced:
    print("no price known for:", sorted(unpriced))
print(f"TOTAL ${total:.2f}" + (f"  (up to {cut} UTC)" if cut else ""))
