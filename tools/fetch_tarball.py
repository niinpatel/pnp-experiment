#!/usr/bin/env python3
"""Download a public GH repo tarball (default branch) and extract to DEST.
Usage: fetch_tarball.py owner/repo DEST"""
import sys, os, tarfile, urllib.request, io
repo, dest = sys.argv[1], sys.argv[2]
os.makedirs(dest, exist_ok=True)
data = urllib.request.urlopen(f"https://api.github.com/repos/{repo}/tarball").read()
with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as t:
    t.extractall(dest)
print("extracted to", dest, os.listdir(dest))
