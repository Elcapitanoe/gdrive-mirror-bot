#!/bin/bash
set -euo pipefail

GDRIVE_LINK="$1"
FILE_NAME="$2"
FILE_PATH="./download/$FILE_NAME"

human_readable_size() {
  local bytes=$1
  local units=("B" "KB" "MB" "GB" "TB" "PB")
  local i=0
  while (( bytes >= 1024 && i < ${#units[@]} - 1 )); do
    bytes=$(awk "BEGIN {print $bytes/1024}")
    ((i++))
  done
  printf "%.2f %s" "$bytes" "${units[$i]}"
}

SHA256_INFO=""
FILE_SIZE="(unknown)"

if [ -f "$FILE_PATH" ]; then
  if command -v sha256sum >/dev/null 2>&1; then
    SHA256_VAL=$(sha256sum "$FILE_PATH" | awk '{print $1}')
  elif command -v shasum >/dev/null 2>&1; then
    SHA256_VAL=$(shasum -a 256 "$FILE_PATH" | awk '{print $1}')
  else
    SHA256_VAL="(sha256sum not available)"
  fi
  SHA256_INFO="$SHA256_VAL"
  FILE_BYTES=$(stat -c%s "$FILE_PATH" 2>/dev/null || stat -f%z "$FILE_PATH")
  FILE_SIZE=$(human_readable_size "$FILE_BYTES")
else
  SHA256_INFO="(file not found)"
  FILE_SIZE="(file not found)"
fi

TIMEZONE="${TIMEZONE:-Asia/Jakarta}"
CURRENT_DATE_FULL=$(TZ="$TIMEZONE" date +"%d %B %Y %H:%M:%S %Z")
CURRENT_DATE_DDMMYYYY=$(TZ="$TIMEZONE" date +"%d/%m/%Y")
CURRENT_DATE_ISO=$(TZ="$TIMEZONE" date +"%Y-%m-%d")
CURRENT_DATE_VERBOSE=$(TZ="$TIMEZONE" date +"%A, %d %B %Y")
CURRENT_TIME_ONLY=$(TZ="$TIMEZONE" date +"%H:%M:%S %Z")

MESSAGE="File successfully uploaded!
Uploaded on: ${CURRENT_DATE_FULL}
Contoh format tanggal:
• DD/MM/YYYY -> ${CURRENT_DATE_DDMMYYYY}
• ISO (YYYY-MM-DD) -> ${CURRENT_DATE_ISO}
• Human (Hari, DD Bulan YYYY) -> ${CURRENT_DATE_VERBOSE}
Waktu saat upload: ${CURRENT_TIME_ONLY}
Mirrored by @domi_adiwijaya

• File: ${FILE_NAME}
• Size: ${FILE_SIZE}
• SHA256: \`${SHA256_INFO}\`

Notes:
• This is a temporary mirror, please download ASAP!"

for CHAT_ID in "$TELEGRAM_CHANNEL_ID" "$TELEGRAM_GROUP_ID" "$TELEGRAM_CHAT_PRIVATE_ID"; do
  if [ -z "${CHAT_ID:-}" ]; then
    continue
  fi
  REPLY_MARKUP=$(printf '{"inline_keyboard":[[{"text":"Download File","url":"%s"},{"text":"Copy Link","switch_inline_query_current_chat":"%s"}]]}' "$GDRIVE_LINK" "$GDRIVE_LINK")
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$CHAT_ID" \
    --data-urlencode text="$MESSAGE" \
    -d disable_web_page_preview=true \
    --data-urlencode reply_markup="$REPLY_MARKUP" >/dev/null || {
      echo "Warning: failed to send message to chat $CHAT_ID" >&2
    }
done
