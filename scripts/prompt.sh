#!/bin/bash
# prompt.sh - Enter an image generation prompt into Gemini and submit
# Usage: prompt.sh "Draw a cute cat"

set -euo pipefail
export DISPLAY=:99

CU_SCRIPTS="$HOME/clawd/skills/computer-use/scripts"
PROMPT="${1:?Usage: prompt.sh \"your image prompt\"}"

echo ">>> Clicking Gemini input field..."
# Click the prompt input area (bottom center of Gemini UI)
"$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"click","x":512,"y":720}'
sleep 0.5

echo ">>> Typing prompt: $PROMPT"
# Type the prompt using xdotool directly for reliability
xdotool type --delay 12 -- "$PROMPT"
sleep 0.5

echo ">>> Submitting prompt..."
"$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"key","key":"Return"}'

echo ">>> Prompt submitted. Image generation started."
echo ">>> Use wait-for-image.sh to poll for completion."
