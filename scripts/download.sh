#!/bin/bash
# download.sh - Download the generated image from Gemini
# Usage: download.sh
#
# Strategy:
# 1. Record current Downloads directory state
# 2. Hover over the image to reveal download button
# 3. Click "Download full size" or the download icon
# 4. Wait for download to complete
# 5. Output the downloaded file path

set -euo pipefail
export DISPLAY=:99

CU_SCRIPTS="$HOME/clawd/skills/computer-use/scripts"
DOWNLOADS_DIR="$HOME/Downloads"

# Record existing files before download
BEFORE=$(ls -t "$DOWNLOADS_DIR"/*.png "$DOWNLOADS_DIR"/*.jpg "$DOWNLOADS_DIR"/*.jpeg "$DOWNLOADS_DIR"/*.webp 2>/dev/null | head -20 || true)

echo ">>> Hovering over generated image area to reveal download button..."
# Move mouse to the center of the generated image area
"$CU_SCRIPTS/action.sh" --no-screenshot '{"type":"move","x":512,"y":400}'
sleep 1.5

echo ">>> Taking screenshot to find download button..."
"$CU_SCRIPTS/action.sh" '{"type":"screenshot"}' | base64 -d > /tmp/openclaw/gemini_hover.png 2>/dev/null || true
echo ">>> Screenshot saved: /tmp/openclaw/gemini_hover.png"
echo ">>> AI agent should analyze screenshot to find and click the download button."
echo ">>> After clicking download, call download-check.sh to find the file."
