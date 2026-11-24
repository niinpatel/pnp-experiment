#!/usr/bin/env python3
"""List a directory of a public GH repo via the contents API. Usage: ghls.py owner/repo path"""
import sys, json, urllib.request
repo, path = sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else ""
url = f"https://api.github.com/repos/{repo}/contents/{path}"
for x in json.load(urllib.request.urlopen(url)):
    print(x["type"], x.get("size"), x["path"])
