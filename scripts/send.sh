#!/bin/bash
# send.sh - Copy downloaded image to OpenClaw media dir and send via Telegram
# Usage: send.sh <chat_id> [caption] [image_path]
#
# If image_path is omitted, uses the newest image in ~/Downloads/

set -euo pipefail

CHAT_ID="${1:?Usage: send.sh <chat_id> [caption] [image_path]}"
CAPTION="${2:-Generated image from Gemini}"
IMAGE_PATH="${3:-}"
MEDIA_DIR="/tmp/openclaw"

mkdir -p "$MEDIA_DIR"

# Find image if not specified
if [ -z "$IMAGE_PATH" ]; then
    IMAGE_PATH=$(find "$HOME/Downloads" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [ -z "$IMAGE_PATH" ]; then
        echo "ERROR: No image files found in ~/Downloads/"
        exit 1
    fi
    echo ">>> Using newest download: $IMAGE_PATH"
fi

# Copy to OpenClaw media directory (required for Telegram)
FILENAME=$(basename "$IMAGE_PATH")
DEST="$MEDIA_DIR/$FILENAME"
cp "$IMAGE_PATH" "$DEST"
echo ">>> Copied to $DEST"

# Send via OpenClaw CLI
echo ">>> Sending to Telegram chat $CHAT_ID..."
openclaw message send --media "$DEST" --channel telegram --to "$CHAT_ID" "$CAPTION"
echo ">>> Sent!"
