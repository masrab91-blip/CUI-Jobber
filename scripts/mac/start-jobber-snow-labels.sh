#!/usr/bin/env bash
# Kick off a Jobber snow-label fix agent on Marc's propel-mac worker.
set -euo pipefail

API_URL="${CURSOR_API_URL:-https://api.cursor.com/v1/agents}"
REPO_URL="${CUI_JOBBER_REPO_URL:-https://github.com/masrab91-blip/CUI-Jobber}"
MACHINE_NAME="${PROPEL_MACHINE_NAME:-propel-mac}"

API_KEY="${CURSOR_API_KEY:-${PROPEL_CURSOR_API_KEY:-}}"
if [[ -z "${API_KEY}" && -f "${HOME}/.config/propel/cursor-api-key" ]]; then
  API_KEY="$(tr -d '[:space:]' < "${HOME}/.config/propel/cursor-api-key")"
fi
if [[ -z "${API_KEY}" ]]; then
  echo "error: set CURSOR_API_KEY or create ~/.config/propel/cursor-api-key" >&2
  exit 1
fi

PROMPT_TEXT="$(cat <<'EOF'
You are running ON Marc's Mac (propel-mac) for Propel Landscape Management. Jobber should already be logged in in the browser. Use computer use / desktop control on THIS machine.

TASK: Fix Propel Landscape Management snow job LABELS in Jobber for the 2026–27 season.

GOAL: At the JOB level (not a one-off visit), set the correct winter priority label on each snow job so it sticks all season. Michael applied labels incorrectly — correct them. Only change labels unless saving requires a minimal edit.

AUTHORITATIVE MAP (use exact Jobber label names if they already exist; match meaning to these tiers):

ZERO TOLERANCE ANY SNOW / ICE • 24 HOURS
- CUI / Huntington Bank
- Shields / Speedway & 7-Eleven
- Ground Masters / CVS & LDS
- Journey Construction
- Excite Commercial Management

LEVEL 1 2-INCH TRIGGER
- Trillium Ventures (6 properties — label each)
- Beeke Investments – Plainfield Ave
- Beeke Investments – Flip House
- VMA Holdings
- Habitat for Humanity / Pleasant Ave
- Broadleaf Brewery / Brewery Vivant
- Raine / Freddy’s

LEVEL 2 2-INCH TRIGGER
- Clayton DeVries

STEPS
1. Open Jobber (logged-in browser).
2. Search by client/job name; names may differ slightly.
3. For each match, set/correct the winter priority JOB label (job-level, not visit).
4. If a client has multiple snow jobs, label each.
5. When done: one clear screenshot of updated labels; report each job as `client | job | old label → new label`, plus not found / ambiguous.

DONE WHEN: every mapped job is labeled correctly, screenshot saved, Mac left usable for Marc. No extra planning — drive Jobber and finish.
EOF
)"

TMP_JSON="$(mktemp)"
cleanup() { rm -f "${TMP_JSON}"; }
trap cleanup EXIT

python3 - "${PROMPT_TEXT}" "${REPO_URL}" "${MACHINE_NAME}" > "${TMP_JSON}" <<'PY'
import json, sys
prompt, repo_url, machine = sys.argv[1], sys.argv[2], sys.argv[3]
print(json.dumps({
    "name": "Jobber snow labels 2026-27",
    "prompt": {"text": prompt},
    "env": {"type": "machine", "name": machine},
    "repos": [{"url": repo_url, "startingRef": "main"}],
}))
PY

echo "Starting Jobber snow-label agent on machine=${MACHINE_NAME} repo=${REPO_URL}"
HTTP_CODE="$(
  curl --silent --show-error --output /tmp/jobber-snow-labels-response.json \
    --write-out '%{http_code}' \
    --request POST \
    --url "${API_URL}" \
    -u "${API_KEY}:" \
    --header 'Content-Type: application/json' \
    --data @"${TMP_JSON}"
)"

if [[ "${HTTP_CODE}" != 200 && "${HTTP_CODE}" != 201 && "${HTTP_CODE}" != 202 ]]; then
  echo "error: API returned HTTP ${HTTP_CODE}" >&2
  head -c 2000 /tmp/jobber-snow-labels-response.json >&2 || true
  echo >&2
  exit 1
fi

python3 - <<'PY'
import json
d=json.load(open("/tmp/jobber-snow-labels-response.json"))
agent=(d.get("agent") or d)
run=(d.get("run") or {})
print("ok")
print("agent_id:", agent.get("id") or d.get("id") or "")
print("run_id:", run.get("id") or d.get("runId") or "")
print("url:", agent.get("url") or d.get("url") or "")
PY
