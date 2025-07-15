#!/bin/bash
set -e

GDRIVE_LINK="$1"
MESSAGE="🚀 *New Upload Available!*\n\n🔗 [Download Here]($GDRIVE_LINK)"

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown"
  
