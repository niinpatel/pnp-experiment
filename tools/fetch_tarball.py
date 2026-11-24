#!/usr/bin/env python3
"""Download a public GH repo tarball and extract to DEST.
Usage: fetch_tarball.py owner/repo DEST [REF]   (REF = commit SHA or branch; default branch if omitted)"""
import sys, os, tarfile, urllib.request, io
repo, dest = sys.argv[1], sys.argv[2]
ref = sys.argv[3] if len(sys.argv) > 3 else ""
os.makedirs(dest, exist_ok=True)
url = f"https://api.github.com/repos/{repo}/tarball" + (f"/{ref}" if ref else "")
data = urllib.request.urlopen(url).read()
with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as t:
    t.extractall(dest)
print("extracted to", dest, os.listdir(dest))
