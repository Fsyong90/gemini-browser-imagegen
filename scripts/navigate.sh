#!/bin/bash
# navigate.sh - Open a new Gemini chat in Chrome on virtual desktop
# Usage: navigate.sh
# Opens a fresh Gemini chat, ready for image prompts

set -euo pipefail
export DISPLAY=:99

CU_SCRIPTS="$HOME/clawd/skills/computer-use/scripts"

echo ">>> Opening new Gemini chat..."

# Method 1: Use keyboard shortcut Ctrl+Shift+O (shown in Gemini UI tooltip)
# Method 2: Navigate via address bar
# Using address bar approach for reliability:

# Focus address bar
xdotool key ctrl+l
sleep 0.3
xdotool key ctrl+a
sleep 0.1

# Type the URL (using xdotool directly to avoid JSON escaping issues)
xdotool type --delay 8 "gemini.google.com/app"
sleep 0.2
xdotool key Return

echo ">>> Waiting for page load..."
sleep 4

# Click "New chat" link (left sidebar) to ensure a fresh conversation
# Coordinates: approximately (96, 299) based on observed UI
"$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"click","x":96,"y":299}'
sleep 2

# Take verification screenshot
echo ">>> Taking screenshot to verify..."
"$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_nav.png 2>/dev/null || true
echo ">>> Navigation complete. Screenshot saved: /tmp/openclaw/gemini_nav.png"
