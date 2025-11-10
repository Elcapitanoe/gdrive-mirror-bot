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

html_escape() {
  local s="$1"
  s=${s//&/&amp;}
  s=${s//</&lt;}
  s=${s//>/&gt;}
  s=${s//\"/&quot;}
  s=${s//\'/&#39;}
  printf '%s' "$s"
}

SHA256_ESCAPED="$(html_escape "$SHA256_INFO")"
FILE_NAME_ESCAPED="$(html_escape "$FILE_NAME")"
FILE_SIZE_ESCAPED="$(html_escape "$FILE_SIZE")"
GDRIVE_LINK_ESCAPED="$(html_escape "$GDRIVE_LINK")"

TIMEZONE="${TIMEZONE:-Asia/Jakarta}"
CURRENT_DATE_FULL=$(TZ="$TIMEZONE" date +"%d/%m/%Y")

MESSAGE="<strong>File successfully uploaded!</strong>
Uploaded on ${CURRENT_DATE_FULL}
Mirrored by @domi_adiwijaya

• File: ${FILE_NAME_ESCAPED}
• Size: ${FILE_SIZE_ESCAPED}

SHA256
<code>${SHA256_ESCAPED}</code>

Notes:
• This is a temporary mirror, please download ASAP!"

for CHAT_ID in "$TELEGRAM_CHANNEL_ID" "$TELEGRAM_GROUP_ID" "$TELEGRAM_CHAT_PRIVATE_ID"; do
  if [ -z "${CHAT_ID:-}" ]; then
    continue
  fi
  REPLY_MARKUP=$(printf '{"inline_keyboard":[[{"text":"Download File","url":"%s"},{"text":"Copy Link","switch_inline_query_current_chat":"%s"}]]}' "$GDRIVE_LINK" "$GDRIVE_LINK")
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$CHAT_ID" \
    --data-urlencode "text=$MESSAGE" \
    -d parse_mode=HTML \
    -d disable_web_page_preview=true \
    --data-urlencode "reply_markup=$REPLY_MARKUP" >/dev/null || {
      echo "Warning: failed to send message to chat $CHAT_ID" >&2
    }
done
