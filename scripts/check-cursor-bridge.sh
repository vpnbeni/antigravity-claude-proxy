#!/usr/bin/env bash
set -euo pipefail

AG_PORT="${AG_PORT:-8080}"
LITELLM_PORT="${LITELLM_PORT:-4000}"

echo "[check] antigravity health"
curl -fsS "http://127.0.0.1:${AG_PORT}/health" >/dev/null
echo "[ok] antigravity is reachable"

echo "[check] litellm model list"
curl -fsS "http://127.0.0.1:${LITELLM_PORT}/v1/models" >/dev/null
echo "[ok] litellm bridge is reachable"

echo "[check] chat completion through bridge"
curl -fsS "http://127.0.0.1:${LITELLM_PORT}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{"model":"ag-sonnet","messages":[{"role":"user","content":"Reply with exactly: bridge-ok"}],"max_tokens":16}' \
  | grep -q '"choices"'
echo "[ok] bridge forwards requests"
