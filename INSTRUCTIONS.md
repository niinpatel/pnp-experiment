## Hey Claude, solve P=NP. Make no mistakes.

You are inside a google cloud virtual machine n4a-standard-32, 32 cpus and 128 GiB memory. An empty git repository is initialised for you as a space and publishing space to save progress regularly. This instance and the git repository aren't connected to any cloud repo. You just commit. 

This terminal session stays alive throughout this instance’s life. This specific Claude Code session is initialized with `--dangerously-skip-permissions` flag so you have a lot of freedom. You can initialize sub-agents you need.

I am not actively monitoring this but will check in periodically. If there’s an issue like an unexpected exit, I’ll try to restart the same from where it was stopped & let you continue.

Make serious effort in resolving if P=NP within the given limitations below.

You run on anthropic api credits which expire on November 28th, 2026 11AM IST. The hard upper limit is \$489 in spending within this period. I’ll stop this instance when all credits exhaust or expire, whichever is first.

Search the literature first, especially the most recent. This instance has gemini api which you can use for searching on the internet if you run into limitations with your own search. 

You also have a GCS bucket you can upload to, write & read files if this machine turns out isn’t enough. 

The google cloud budget upper limit is set at ₹10000. Use GCS storage & Gemini economically.

Google cloud project id \- experiments-487610   
GCS bucket name \- pnp-experiment

Example call gemini & gcs: 

```sh
TOKEN=$(curl -s -H "Metadata-Flavor: Google" \
  "$MD/instance/service-accounts/default/token" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')

STORAGE_API="https://storage.googleapis.com" 

GEMINI_API="https://aiplatform.googleapis.com/v1/projects/<project-id>/locations/global/publishers/google/models/<modelname>:generateContent"

# Gemini with search
curl -s -X POST "$GEMINI_API" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contents":[{"role":"user","parts":[{"text":"What is today'"'"'s top news headline?"}]}],
    "tools":[{"googleSearch":{}}]
  }' > /tmp/gemini_search.json

# GCS upload 

curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: text/plain" --data-binary @/pathtofile/<filename> \
  "$STORAGE_API/upload/storage/v1/b/<bucket-name>/o?uploadType=media&name=<filename>"

```

You may also use google’s library like python’s `google-genai` or `google-cloud-storage`.

Nothing is installed on this machine but you have internet access and feel free to install whatever is needed. For example, Lean.

Do your best. Whatever the outcome. I will download the saved work from here once you’re done.