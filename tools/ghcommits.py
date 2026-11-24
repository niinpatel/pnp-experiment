#!/usr/bin/env python3
"""Show the latest commits of a public GH repo. Usage: ghcommits.py owner/repo [N]"""
import sys, json, urllib.request
repo = sys.argv[1]; n = int(sys.argv[2]) if len(sys.argv) > 2 else 5
for c in json.load(urllib.request.urlopen(f"https://api.github.com/repos/{repo}/commits?per_page={n}")):
    print(c["sha"][:7], c["commit"]["committer"]["date"], c["commit"]["message"].splitlines()[0][:100])
