#!/bin/bash
set -euo pipefail

GDRIVE_LINK="$1"
FILE_NAME="$2"

SHA256_INFO=""
if [ -f "./download/$FILE_NAME" ]; then
  if command -v sha256sum >/dev/null 2>&1; then
    SHA256_VAL=$(sha256sum "./download/$FILE_NAME" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then
    SHA256_VAL=$(shasum -a 256 "./download/$FILE_NAME" | awk '{print $1}')
  else
    SHA256_VAL="(sha256sum not available)"
  fi
  FILE_SIZE=$(du -h "./download/$FILE_NAME" | awk '{print $1}')
  SHA256_INFO="\nSize: ${FILE_SIZE}\nSHA256: ${SHA256_VAL}"
else
  SHA256_INFO="\nSHA256: (file not found)"
fi

MESSAGE="Upload completed!
File: ${FILE_NAME}
Link: ${GDRIVE_LINK}${SHA256_INFO}"

for CHAT_ID in "$TELEGRAM_CHANNEL_ID" "$TELEGRAM_GROUP_ID" "$TELEGRAM_CHAT_PRIVATE_ID"; do
  if [ -z "${CHAT_ID:-}" ]; then
    continue
  fi

  REPLY_MARKUP=$(printf '{"inline_keyboard":[[{"text":"Download File","url":"%s"}]]}' "$GDRIVE_LINK")

  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$CHAT_ID" \
    --data-urlencode text="$MESSAGE" \
    -d disable_web_page_preview=true \
    --data-urlencode reply_markup="$REPLY_MARKUP" >/dev/null || {
      echo "Warning: gagal kirim ke chat $CHAT_ID" >&2
    }
done
