#!/usr/bin/env bash
# Kick off a Jobber snow-label fix agent on Marc's propel-mac worker.
# Prefers Cursor Cloud Agents API when a real API key is present; otherwise
# falls back to local `agent -p` using the logged-in CLI session.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROMPT_FILE="${REPO_ROOT}/prompts/jobber-snow-labels.md"
API_URL="${CURSOR_API_URL:-https://api.cursor.com/v1/agents}"
REPO_URL="${CUI_JOBBER_REPO_URL:-https://github.com/masrab91-blip/CUI-Jobber}"
MACHINE_NAME="${PROPEL_MACHINE_NAME:-propel-mac}"
AGENT_BIN="${AGENT_BIN:-/Users/marcs/.local/bin/agent}"

if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "error: prompt not found: ${PROMPT_FILE}" >&2
  exit 1
fi

looks_like_api_key() {
  local k="$1"
  [[ -n "${k}" ]] || return 1
  [[ "${k}" != cd\ * ]] || return 1
  [[ "${#k}" -ge 20 ]] || return 1
  [[ "${k}" != *$'\n'* ]] || return 1
  return 0
}

API_KEY="${CURSOR_API_KEY:-${PROPEL_CURSOR_API_KEY:-}}"
if [[ -z "${API_KEY}" && -f "${HOME}/.config/propel/cursor-api-key" ]]; then
  API_KEY="$(tr -d '[:space:]' < "${HOME}/.config/propel/cursor-api-key")"
fi

PROMPT_TEXT="$(cat "${PROMPT_FILE}")"
if [[ $# -gt 0 ]]; then
  PROMPT_TEXT+=$'\n\n## Operator note\n'
  PROMPT_TEXT+="$*"
fi

if looks_like_api_key "${API_KEY:-}"; then
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

  echo "Starting Jobber snow-label agent via API on machine=${MACHINE_NAME} repo=${REPO_URL}"
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
print("mode: api")
print("agent_id:", agent.get("id") or d.get("id") or "")
print("run_id:", run.get("id") or d.get("runId") or "")
print("url:", agent.get("url") or d.get("url") or "")
PY
  exit 0
fi

echo "note: no valid CURSOR_API_KEY / ~/.config/propel/cursor-api-key — using local agent CLI fallback" >&2
if [[ ! -x "${AGENT_BIN}" ]]; then
  echo "error: agent CLI not found at ${AGENT_BIN}" >&2
  exit 1
fi

LOG_DIR="${HOME}/Library/Logs"
mkdir -p "${LOG_DIR}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_LOG="${LOG_DIR}/jobber-snow-labels-run-${STAMP}.log"
PROMPT_TMP="${LOG_DIR}/jobber-snow-labels-prompt-${STAMP}.txt"
WRAPPER_TMP="$(mktemp)"
cleanup2() { rm -f "${WRAPPER_TMP}"; }
trap cleanup2 EXIT
printf '%s' "${PROMPT_TEXT}" > "${PROMPT_TMP}"
cat > "${WRAPPER_TMP}" <<EOF
#!/bin/bash
set -euo pipefail
cd "${REPO_ROOT}"
exec "${AGENT_BIN}" -p --force --trust --workspace "${REPO_ROOT}" "\$(cat '${PROMPT_TMP}')"
EOF
chmod +x "${WRAPPER_TMP}"

echo "Starting Jobber snow-label fix via local agent CLI (log: ${OUT_LOG})"
nohup "${WRAPPER_TMP}" > "${OUT_LOG}" 2>&1 &
PID=$!
echo "ok"
echo "mode: local-cli"
echo "pid: ${PID}"
echo "log: ${OUT_LOG}"
echo "prompt: ${PROMPT_TMP}"
