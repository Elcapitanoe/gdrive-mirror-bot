#!/bin/bash
set -e

GDRIVE_LINK="$1"
FILE_NAME="$2"

MESSAGE="🚀 New Mirror Uploaded!

File Name: $FILE_NAME

🔗 $GDRIVE_LINK"

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="$MESSAGE"
