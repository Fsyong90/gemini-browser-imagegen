#!/bin/bash
# wait-for-image.sh - Poll Gemini until image generation is complete
# Usage: wait-for-image.sh [max_wait_seconds]
# Default: 60 seconds, checks every 10 seconds

set -euo pipefail
export DISPLAY=:99

CU_SCRIPTS="$HOME/clawd/skills/computer-use/scripts"
MAX_WAIT="${1:-60}"
INTERVAL=10
ELAPSED=0

echo ">>> Waiting for Gemini to generate image (max ${MAX_WAIT}s)..."

while [ "$ELAPSED" -lt "$MAX_WAIT" ]; do
    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
    echo ">>> ${ELAPSED}s elapsed, taking screenshot..."

    # Save screenshot to file for inspection
    SCREENSHOT="/tmp/openclaw/gemini_wait_${ELAPSED}.png"
    "$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"screenshot"}' | base64 -d > "$SCREENSHOT" 2>/dev/null || true

    if [ -f "$SCREENSHOT" ] && [ -s "$SCREENSHOT" ]; then
        echo ">>> Screenshot saved: $SCREENSHOT"
        echo ">>> Check if image generation is complete."
        # The caller (AI agent) should analyze the screenshot to determine if done
    fi
done

echo ">>> Wait complete after ${ELAPSED}s. Take a final screenshot to verify."
"$CU_SCRIPTS/action.sh" '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_final.png 2>/dev/null || true
echo ">>> Final screenshot: /tmp/openclaw/gemini_final.png"
