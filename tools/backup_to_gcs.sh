#!/usr/bin/env bash
# Bundle the work branch and upload it to the GCS bucket pnp-experiment (as a second copy).
# Run from the worktree root.
set -eu
OUT=${CLAUDE_JOB_DIR:-/tmp}/tmp/pnp-work.bundle
git bundle create "$OUT" worktree-pnp-work >/dev/null 2>&1
MD="http://metadata.google.internal/computeMetadata/v1"
TOKEN=$(curl -s -H "Metadata-Flavor: Google" "$MD/instance/service-accounts/default/token" | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" --data-binary @"$OUT" \
  "https://storage.googleapis.com/upload/storage/v1/b/pnp-experiment/o?uploadType=media&name=pnp-work.bundle"
