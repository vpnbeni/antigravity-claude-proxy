#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AG_PORT="${AG_PORT:-8080}"
LITELLM_PORT="${LITELLM_PORT:-4000}"
LITELLM_CONFIG="${LITELLM_CONFIG:-$ROOT_DIR/scripts/cursor-bridge-litellm.yaml}"
LITELLM_VENV="${LITELLM_VENV:-$ROOT_DIR/.venv-cursor-bridge}"

if [[ ! -x "$LITELLM_VENV/bin/litellm" ]]; then
  echo "LiteLLM not found in $LITELLM_VENV."
  echo "Run: python3 -m venv .venv-cursor-bridge && . .venv-cursor-bridge/bin/activate && pip install \"litellm[proxy]\" hypercorn"
  exit 1
fi

if [[ ! -f "$LITELLM_CONFIG" ]]; then
  echo "LiteLLM config file not found: $LITELLM_CONFIG"
  exit 1
fi

AG_PID=""
LLM_PID=""

cleanup() {
  set +e
  [[ -n "$LLM_PID" ]] && kill "$LLM_PID" 2>/dev/null || true
  [[ -n "$AG_PID" ]] && kill "$AG_PID" 2>/dev/null || true
  wait "$LLM_PID" 2>/dev/null || true
  wait "$AG_PID" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"

echo "[cursor-bridge] starting antigravity proxy on :$AG_PORT"
HOST=127.0.0.1 PORT="$AG_PORT" npm start &
AG_PID=$!

echo "[cursor-bridge] starting litellm bridge on :$LITELLM_PORT"
"$LITELLM_VENV/bin/litellm" --host 127.0.0.1 --config "$LITELLM_CONFIG" --port "$LITELLM_PORT" --run_hypercorn --drop_params &
LLM_PID=$!

echo "[cursor-bridge] running"
echo "[cursor-bridge] antigravity health: http://127.0.0.1:$AG_PORT/health"
echo "[cursor-bridge] openai base url for Cursor: http://127.0.0.1:$LITELLM_PORT/v1"
echo "[cursor-bridge] press Ctrl+C to stop both"

wait "$AG_PID" "$LLM_PID"
