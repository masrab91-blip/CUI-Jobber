#!/usr/bin/env bash
# Kick off a LIVE CUI winter snow-entry agent on Marc's propel-mac worker.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROMPT_FILE="${REPO_ROOT}/prompts/winter-entry-run.md"
API_URL="${CURSOR_API_URL:-https://api.cursor.com/v1/agents}"
REPO_URL="${CUI_JOBBER_REPO_URL:-https://github.com/masrab91-blip/CUI-Jobber}"
MACHINE_NAME="${PROPEL_MACHINE_NAME:-propel-mac}"

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "error: prompt not found: ${PROMPT_FILE}" >&2
  exit 1
fi

API_KEY="${CURSOR_API_KEY:-}"
if [[ -z "${API_KEY}" && -f "${HOME}/.config/propel/cursor-api-key" ]]; then
  API_KEY="$(tr -d '[:space:]' < "${HOME}/.config/propel/cursor-api-key")"
fi
if [[ -z "${API_KEY}" ]]; then
  echo "error: set CURSOR_API_KEY or create ~/.config/propel/cursor-api-key" >&2
  exit 1
fi

PROMPT_TEXT="$(cat "${PROMPT_FILE}")"
# Optional operator override appended after the runbook prompt.
if [[ $# -gt 0 ]]; then
  PROMPT_TEXT+=$'\n\n## Operator note\n'
  PROMPT_TEXT+="$*"
fi

TMP_JSON="$(mktemp)"
cleanup() { rm -f "${TMP_JSON}"; }
trap cleanup EXIT

# Build JSON body without printing the API key.
python3 - "${PROMPT_TEXT}" "${REPO_URL}" "${MACHINE_NAME}" > "${TMP_JSON}" <<'PY'
import json, sys
prompt, repo_url, machine = sys.argv[1], sys.argv[2], sys.argv[3]
print(json.dumps({
    "name": "CUI winter snow entry",
    "prompt": {"text": prompt},
    "env": {"type": "machine", "name": machine},
    "repos": [{"url": repo_url, "startingRef": "main"}],
}))
PY

echo "Starting winter entry agent on machine=${MACHINE_NAME} repo=${REPO_URL}"
HTTP_CODE="$(
  curl --silent --show-error --output /tmp/cui-winter-entry-response.json \
    --write-out '%{http_code}' \
    --request POST \
    --url "${API_URL}" \
    -u "${API_KEY}:" \
    --header 'Content-Type: application/json' \
    --data @"${TMP_JSON}"
)"

if [[ "${HTTP_CODE}" != 200 && "${HTTP_CODE}" != 201 && "${HTTP_CODE}" != 202 ]]; then
  echo "error: API returned HTTP ${HTTP_CODE}" >&2
  # Print a short response preview only (never echo the API key).
  head -c 2000 /tmp/cui-winter-entry-response.json >&2 || true
  echo >&2
  exit 1
fi

python3 - <<'PY'
import json
d=json.load(open("/tmp/cui-winter-entry-response.json"))
agent=(d.get("agent") or d)
run=(d.get("run") or {})
print("ok")
print("agent_id:", agent.get("id") or d.get("id") or "")
print("run_id:", run.get("id") or d.get("runId") or "")
print("url:", agent.get("url") or d.get("url") or "")
PY
