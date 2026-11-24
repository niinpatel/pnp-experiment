#!/usr/bin/env bash
# Bundle every branch of the repository and upload it to the GCS bucket pnp-experiment (as a
# second copy). Run from the repository root. (Until 2026-11-24 this bundled only the branch
# worktree-pnp-work; that branch was merged into main, so the bundle now holds all branches.)
set -eu
OUT=${CLAUDE_JOB_DIR:-/tmp}/tmp/pnp-work.bundle
mkdir -p "$(dirname "$OUT")"
git bundle create "$OUT" --all >/dev/null 2>&1
MD="http://metadata.google.internal/computeMetadata/v1"
TOKEN=$(curl -s -H "Metadata-Flavor: Google" "$MD/instance/service-accounts/default/token" | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" --data-binary @"$OUT" \
  "https://storage.googleapis.com/upload/storage/v1/b/pnp-experiment/o?uploadType=media&name=pnp-work.bundle"
