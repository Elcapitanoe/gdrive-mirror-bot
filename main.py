import os
import base64
import time
import requests
from urllib.parse import urlparse
from dotenv import load_dotenv
import platform
import socket
import datetime
import psutil

from telegram import Update
from telegram.constants import ChatAction
from telegram.ext import Application, CommandHandler, ContextTypes

load_dotenv()

BOT_TOKEN       = os.getenv("BOT_TOKEN")
GH_PUSH_TOKEN   = os.getenv("GH_PUSH")
AUTHORIZED_USER = "domi_adiwijaya"
REPO_OWNER      = "Elcapitanoe"
REPO_NAME       = "gdrive-mirror-bot"
CONFIG_PATH     = "config.txt"


def is_valid_url(url: str) -> bool:
    try:
        parsed = urlparse(url)
        return parsed.scheme in ("http", "https") and bool(parsed.netloc)
    except:
        return False


def format_bytes(value: int) -> str:
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if value < 1024:
            return f"{value:.2f} {unit}"
        value /= 1024
    return f"{value:.2f} PB"


async def start(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "✅ MirrorBot engine is live.\nUse /mirror <url> to inject tasks into the mirror pipeline."
    )


async def ping(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    start_time = time.time()
    await update.message.chat.send_action(action=ChatAction.TYPING)
    latency = int((time.time() - start_time) * 1000)
    await update.message.reply_text(f"✅ MirrorNode online. Response latency: {latency} ms")


async def about(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "🧩 MirrorBot is an autonomous backend system that queues direct download sources "
        "and performs server-to-server binary mirroring across cloud infrastructure. "
        "Optimized for sysadmins and automation pipelines."
    )


async def help_command(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "📘 MirrorBot Command Reference\n\n"
        "/start - Initialize connection\n"
        "/ping - Check mirror engine availability\n"
        "/about - Describe mirror system architecture\n"
        "/mirror <url> - Queue remote binary for internal mirroring\n"
        "/status - Show host system runtime metrics"
    )


async def mirror(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    if user.username != AUTHORIZED_USER:
        await update.message.reply_text("⛔ Permission Denied: Unauthorized user.")
        return

    if len(ctx.args) != 1:
        await update.message.reply_text("⚠️ Usage: /mirror <direct_download_url>")
        return

    url = ctx.args[0]

    if not is_valid_url(url):
        await update.message.reply_text("❌ Invalid Input: Malformed URL.")
        return

    try:
        headers = {
            "User-Agent": "TelegramBot File Validator",
            "Range": "bytes=0-1023"
        }
        response = requests.get(url, headers=headers, stream=True, timeout=10)
        chunk = next(response.iter_content(chunk_size=1024), None)

        content_type = response.headers.get("Content-Type", "").lower()
        content_length = response.headers.get("Content-Length", "")

        if not chunk or not chunk.strip():
            await update.message.reply_text("❌ Invalid or empty response. Resource may not be a direct file.")
            return

        if "html" in content_type or not content_length.isdigit():
            await update.message.reply_text("❌ Invalid resource. Target is not a downloadable binary.")
            return

    except requests.RequestException as e:
        await update.message.reply_text(f"❌ Network Error: {str(e)}")
        return

    api_url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{CONFIG_PATH}"
    headers = {
        "Authorization": f"token {GH_PUSH_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    encoded = base64.b64encode(url.encode()).decode()

    github_resp = requests.get(api_url, headers=headers)

    if github_resp.status_code == 200:
        sha = github_resp.json().get("sha")
        payload = {
            "message": f"Validated push from Telegram - {user.username}",
            "content": encoded,
            "sha": sha
        }
        put_resp = requests.put(api_url, headers=headers, json=payload)
        msg = "✅ File reference synchronized to mirror queue. Task has been registered." if put_resp.status_code == 200 else "❌ Failed to update mirror queue."

    elif github_resp.status_code == 404:
        payload = {
            "message": f"Validated creation from Telegram - {user.username}",
            "content": encoded
        }
        cr_resp = requests.put(api_url, headers=headers, json=payload)
        msg = "✅ File reference injected to new mirror queue. Initialization complete." if cr_resp.status_code == 201 else "❌ Failed to create mirror queue."

    else:
        msg = f"⚠️ Sync error: mirror queue API responded with HTTP {github_resp.status_code}"

    await update.message.reply_text(msg)


async def status(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    boot_time = datetime.datetime.fromtimestamp(psutil.boot_time())
    uptime = datetime.datetime.now() - boot_time
    days = uptime.days
    hours, remainder = divmod(uptime.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    uptime_str = f"{days * 24 + hours} Hours {minutes} Minutes {seconds} Seconds"

    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage("/")
    net = psutil.net_io_counters()

    text = (
        "🧠 *MirrorNode Runtime Snapshot*\n\n"
        f"• Uptime : {uptime_str}\n"
        f"• CPU Load : {cpu:5.2f}%\n"
        f"• RAM Usage : {format_bytes(mem.used)} / {format_bytes(mem.total)} ({mem.percent:.1f}%)\n"
        f"• Disk Usage : {format_bytes(disk.used)} / {format_bytes(disk.total)} ({disk.percent:.1f}%)\n"
        f"• Network : Sent {format_bytes(net.bytes_sent)} | Received {format_bytes(net.bytes_recv)}"
    )
    await update.message.reply_text(text, parse_mode="Markdown")


def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("ping", ping))
    app.add_handler(CommandHandler("about", about))
    app.add_handler(CommandHandler("help", help_command))
    app.add_handler(CommandHandler("mirror", mirror))
    app.add_handler(CommandHandler("status", status))
    print("✅ MirrorBot is running...")
    app.run_polling()


if __name__ == "__main__":
    main()
