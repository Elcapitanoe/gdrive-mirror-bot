# Google Drive Mirror Bot

A GitHub Actions-powered automation that downloads a file from a direct link (defined in `config.txt`), uploads it to Google Drive using the **Google Drive API**, and sends the shareable link to a Telegram channel via bot.

---

## Setup Steps

1. **Fork this repository** or upload it to your own GitHub repo.
2. **Add the following GitHub Secrets** under  
   `Settings → Secrets and variables → Actions → New repository secret`:

   | Secret Name              | Description                                             |
   |--------------------------|---------------------------------------------------------|
   | `TELEGRAM_BOT_TOKEN`     | Token from [@BotFather](https://t.me/BotFather)         |
   | `TELEGRAM_CHAT_ID`       | Telegram channel or group ID (e.g., `-1001234567890`)   |
   | `GDRIVE_CLIENT_ID`       | OAuth 2.0 Client ID from Google Cloud Console           |
   | `GDRIVE_CLIENT_SECRET`   | OAuth 2.0 Client Secret from Google Cloud Console       |
   | `GDRIVE_REFRESH_TOKEN`   | Refresh Token generated via OAuth Playground            |
   | `GDRIVE_FOLDER_ID`       | Target folder ID in Google Drive                        |

3. **Edit `config.txt`** and replace its content with a **direct download link**, like: https://example.com/file.zip

4. **Commit your changes**  
Once pushed, GitHub Actions will automatically:
- Download the file
- ☁Upload it to your Google Drive folder
- Send the Google Drive link to your Telegram channel

---

## Supported Download Links

Use only direct file URLs, like:

- `https://example.com/file.zip`
- `https://yourdomain.com/device/rom-latest.zip`

The file must be publicly downloadable without login, redirects, or captchas.

---

## Automation Behavior

- The workflow only runs if `config.txt` is changed
- Google Drive links are automatically made shareable
- Telegram messages use Markdown formatting
