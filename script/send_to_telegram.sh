#!/bin/bash
set -e

# Ambil argumen
GDRIVE_LINK="$1"
FILE_NAME="$2"

# Fungsi untuk escape karakter MarkdownV2
escape_md() {
  echo "$1" | sed -e 's/\\/\\\\/g' \
                  -e 's/\./\\./g' \
                  -e 's/\*/\\*/g' \
                  -e 's/_/\\_/g' \
                  -e 's/\[/\\[/g' \
                  -e 's/\]/\\]/g' \
                  -e 's/(/\\(/g' \
                  -e 's/)/\\)/g' \
                  -e 's/\~/\\~/g' \
                  -e 's/\`/\\`/g' \
                  -e 's/>/\\>/g' \
                  -e 's/#/\\#/g' \
                  -e 's/\+/\\+/g' \
                  -e 's/-/\\-/g' \
                  -e 's/=/\\=/g' \
                  -e 's/{/\\{/g' \
                  -e 's/}/\\}/g' \
                  -e 's/!/\\!/g'
}

# Escape input agar tidak rusak saat dikirim ke Telegram
ESCAPED_FILE_NAME=$(escape_md "$FILE_NAME")
ESCAPED_GDRIVE_LINK=$(escape_md "$GDRIVE_LINK")

# Format pesan
MESSAGE="🚀 *New Mirror Uploaded!*\n\nFile Name: \`$ESCAPED_FILE_NAME\`\n\n🔗 [Download Here]($ESCAPED_GDRIVE_LINK)"

# Kirim ke Telegram
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="$MESSAGE" \
  -d parse_mode="MarkdownV2"
