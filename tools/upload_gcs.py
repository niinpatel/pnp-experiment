#!/usr/bin/env python3
"""Upload bytes to the GCS bucket pnp-experiment.
Usage: upload_gcs.py OBJECT_NAME FILE
       upload_gcs.py OBJECT_NAME --gh-tarball owner/repo REF   (download a GH tarball at REF and upload it)"""
import sys, json, urllib.request
MD = "http://metadata.google.internal/computeMetadata/v1"
tok = json.load(urllib.request.urlopen(urllib.request.Request(
    MD + "/instance/service-accounts/default/token", headers={"Metadata-Flavor": "Google"})))["access_token"]
name = sys.argv[1]
if sys.argv[2] == "--gh-tarball":
    data = urllib.request.urlopen(f"https://api.github.com/repos/{sys.argv[3]}/tarball/{sys.argv[4]}").read()
else:
    data = open(sys.argv[2], "rb").read()
req = urllib.request.Request(
    f"https://storage.googleapis.com/upload/storage/v1/b/pnp-experiment/o?uploadType=media&name={name}",
    data=data, headers={"Authorization": "Bearer " + tok, "Content-Type": "application/octet-stream"})
r = urllib.request.urlopen(req)
print("HTTP", r.status, name, len(data), "bytes")
