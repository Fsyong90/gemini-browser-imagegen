#!/bin/bash
# download-check.sh - Find the most recently downloaded image file
# Usage: download-check.sh [downloads_dir]
# Outputs the path of the newest image file in Downloads

set -euo pipefail

DOWNLOADS_DIR="${1:-$HOME/Downloads}"

echo ">>> Checking for new downloads in $DOWNLOADS_DIR..."

# Find newest image file (png, jpg, jpeg, webp)
NEWEST=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "$NEWEST" ]; then
    echo "ERROR: No image files found in $DOWNLOADS_DIR"
    exit 1
fi

# Check if file was modified in the last 2 minutes (120 seconds)
FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$NEWEST") ))
if [ "$FILE_AGE" -gt 120 ]; then
    echo "WARNING: Newest image is ${FILE_AGE}s old — may not be the new download"
fi

FILE_SIZE=$(stat -c %s "$NEWEST")
echo ">>> Found: $NEWEST ($(( FILE_SIZE / 1024 ))KB, ${FILE_AGE}s ago)"
echo "$NEWEST"
