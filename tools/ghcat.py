#!/usr/bin/env python3
"""Print raw files from a public GH repo (main branch). Usage: ghcat.py owner/repo path [path...]
   Use -o DIR as first arg to save files into DIR instead of printing."""
import sys, os, urllib.request
args = sys.argv[1:]
out = None
if args[0] == "-o":
    out = args[1]; args = args[2:]
repo, paths = args[0], args[1:]
for p in paths:
    data = urllib.request.urlopen(f"https://raw.githubusercontent.com/{repo}/main/{p}").read()
    if out:
        dst = os.path.join(out, p); os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(data); print("saved", dst)
    else:
        print(f"######## {p}"); print(data.decode(errors="replace"))
