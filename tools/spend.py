#!/usr/bin/env python3
"""Rough spend estimate from Claude Code session logs (token usage by model, at two price guesses)."""
import json, glob, os
tot = {}
for f in glob.glob(os.path.expanduser('~/.claude/projects/**/*.jsonl'), recursive=True):
    for line in open(f):
        try:
            d = json.loads(line)
        except Exception:
            continue
        m = d.get("message")
        if not isinstance(m, dict) or not m.get("usage"):
            continue
        t = tot.setdefault(m.get("model", "?"), {})
        for k, v in m["usage"].items():
            if isinstance(v, int):
                t[k] = t.get(k, 0) + v
for mdl, t in tot.items():
    print(mdl, t)
    for lab, (i, o) in {"$5/$25 per Mtok": (5, 25), "$15/$75 per Mtok": (15, 75)}.items():
        c = (t.get("input_tokens", 0) * i + t.get("output_tokens", 0) * o
             + t.get("cache_creation_input_tokens", 0) * i * 1.25 + t.get("cache_read_input_tokens", 0) * i * 0.1)
        print("   ", lab, "->", round(c / 1e6, 1), "USD")
