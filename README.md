# Google Drive Mirror Bot

A lightweight GitHub Actions-powered bot that:

1. Downloads a file from a direct URL (`config.txt`)
2. Uploads it to Google Drive using the **Google Drive API**
3. Sends the shareable Google Drive link to your Telegram channel or group

---

## Quick Setup

1. **Fork this repo** or upload it to your own GitHub repository.
2. **Add these GitHub secrets** under  
   `Settings → Secrets and variables → Actions → New repository secret`:

   | Secret Name             | What it does                                              |
   |-------------------------|-----------------------------------------------------------|
   | `TELEGRAM_BOT_TOKEN`    | Bot token from [@BotFather](https://t.me/BotFather)       |
   | `TELEGRAM_CHAT_ID`      | Your channel/group ID (example: `-1001234567890`)         |
   | `GDRIVE_CLIENT_ID`      | OAuth Client ID from Google Cloud Console                 |
   | `GDRIVE_CLIENT_SECRET`  | OAuth Client Secret from Google Cloud Console             |
   | `GDRIVE_REFRESH_TOKEN`  | Refresh token from Google OAuth Playground                |
   | `GDRIVE_FOLDER_ID`      | The destination folder ID in Google Drive                 |

3. **Edit `config.txt`**  
   Replace its content with a direct file URL, such as:  
   `https://example.com/firmware-update.zip`

4. **Push your changes**  
   Once committed, GitHub Actions will:

   - Download the file
   - Upload it to your Google Drive folder
   - Send the Google Drive link to your Telegram

---

## Supported File URLs

Only **direct download links** are supported, for example:

- `https://example.com/file.zip`
- `https://cdn.xiameme.com/sweet.zip`
- `https://selaluviral.org/nenek_sama_kakek_berduaan.3gp?v=1`
- `https://aselole.id/download?filename=hohohihe_viral.3gp`

> Links must be publicly downloadable, no login, no redirects, no captchas.

---

## How It Works

- The workflow only runs when `config.txt` is modified
- The uploaded file will be set to "shareable" by default
- Telegram messages are sent using Markdown formatting for better readability
