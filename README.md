# gdrive-mirror-bot

A GitHub Actions-powered automation that downloads a file from a direct link (defined in `config.txt`), uploads it to Google Drive using `rclone`, and sends the shareable link to a Telegram channel using a bot.

## 🔧 Setup Steps

1. Fork this repo or upload to your own GitHub repository.
2. Add GitHub Secrets:
   - `TELEGRAM_BOT_TOKEN`
   - `TELEGRAM_CHAT_ID`
   - `RCLONE_CONFIG` (base64 of your rclone.conf)
3. Update `config.txt` with a direct download link.
4. Commit the change and GitHub Actions will automatically:
   - Download the file
   - Upload to Google Drive
   - Send the link to your Telegram channel

You're done 🚀
