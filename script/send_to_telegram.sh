#!/bin/bash
set -e

GDRIVE_LINK="$1"
FILE_NAME="$2"

# Buat pesan dengan newline yang dirender Telegram
MESSAGE=$(echo -e "🚀 *New Mirror Uploaded!*\n\nFile Name: $FILE_NAME\n\n🔗 [Download Here]($GDRIVE_LINK)")

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown"
