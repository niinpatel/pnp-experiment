#!/usr/bin/env python3
"""Query Gemini (Vertex AI) with Google Search grounding.
Usage: gemini_search.py "question" [model]
Prints answer text followed by grounding source URLs.
NOTE: output is unverified; every citation must be checked against its primary source."""
import sys, json, urllib.request
MD = "http://metadata.google.internal/computeMetadata/v1"
def token():
    r = urllib.request.Request(MD + "/instance/service-accounts/default/token", headers={"Metadata-Flavor": "Google"})
    return json.load(urllib.request.urlopen(r))["access_token"]
q = sys.argv[1]
model = sys.argv[2] if len(sys.argv) > 2 else "gemini-3.5-flash"
url = f"https://aiplatform.googleapis.com/v1/projects/experiments-487610/locations/global/publishers/google/models/{model}:generateContent"
body = {"contents": [{"role": "user", "parts": [{"text": q}]}], "tools": [{"googleSearch": {}}]}
req = urllib.request.Request(url, data=json.dumps(body).encode(),
                             headers={"Authorization": "Bearer " + token(), "Content-Type": "application/json"})
resp = json.load(urllib.request.urlopen(req, timeout=300))
c = resp["candidates"][0]
print("".join(p.get("text", "") for p in c["content"]["parts"] if not p.get("thought")))
print("\n--- SOURCES ---")
for ch in c.get("groundingMetadata", {}).get("groundingChunks", []):
    w = ch.get("web", {})
    print(w.get("title"), w.get("uri"))
