#!/bin/bash
set -euo pipefail

GDRIVE_LINK="$1"
FILE_NAME="$2"

BASE_TEXT=$(printf 'New Mirror Uploaded!\n\nFile Name: %s\n' "$FILE_NAME")

GDRIVE_LINK_ESC=$(printf '%s' "$GDRIVE_LINK" | sed 's/"/\\"/g')

for CHAT_ID in "$TELEGRAM_CHANNEL_ID" "$TELEGRAM_GROUP_ID" "$TELEGRAM_CHAT_PRIVATE_ID"; do
  REPLY_MARKUP=$(printf '{"inline_keyboard":[[{"text":"Download File","url":"%s"}]]}' "$GDRIVE_LINK_ESC")

  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$CHAT_ID" \
    --data-urlencode text="$BASE_TEXT" \
    -d disable_web_page_preview=true \
    --data-urlencode reply_markup="$REPLY_MARKUP" >/dev/null
done
