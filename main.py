from telegram.ext import Application, CommandHandler
import subprocess, os

REPO_DIR = os.getcwd()
GITHUB_TOKEN = os.environ["GH_TOKEN"]
GITHUB_USERNAME = "Elcapitanoe"
AUTHORIZED_USERNAME = "domi_adiwijaya"

def is_authorized(user): return user.username == AUTHORIZED_USERNAME

async def mirror(update, context):
    user = update.effective_user
    if not is_authorized(user):
        await update.message.reply_text("❌ Unauthorized.")
        return

    if not context.args:
        await update.message.reply_text("❌ Usage:\n/mirror <url>")
        return

    url = context.args[0]
    await update.message.reply_text(f"🔁 Mirroring: `{url}`", parse_mode="Markdown")

    with open("config.txt", "w") as f:
        f.write(url)

    subprocess.run("git config user.email 'bot@example.com'", shell=True, cwd=REPO_DIR)
    subprocess.run("git config user.name 'MirrorBot'", shell=True, cwd=REPO_DIR)
    subprocess.run("git add config.txt", shell=True, cwd=REPO_DIR)
    subprocess.run("git commit -m 'auto: mirror new file'", shell=True, cwd=REPO_DIR)
    subprocess.run(
        f"git push https://{GITHUB_TOKEN}@github.com/{GITHUB_USERNAME}/gdrive-mirror-bot.git",
        shell=True, cwd=REPO_DIR
    )

    await update.message.reply_text("✅ Mirror triggered!")

async def start(update, context):
    user = update.effective_user
    await update.message.reply_text(f"👋 Hello {user.username}!\nID: `{user.id}`", parse_mode="Markdown")

async def ping(update, context): await update.message.reply_text("🏓 Pong!")

async def status(update, context):
    user = update.effective_user
    if not is_authorized(user):
        await update.message.reply_text("❌ Unauthorized.")
        return

    if os.path.exists("config.txt"):
        with open("config.txt") as f:
            url = f.read().strip()
        await update.message.reply_text(f"📄 Last mirror:\n`{url}`", parse_mode="Markdown")
    else:
        await update.message.reply_text("⚠️ No config.txt found.")

def main():
    app = Application.builder().token(os.environ["BOT_TOKEN"]).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("mirror", mirror))
    app.add_handler(CommandHandler("ping", ping))
    app.add_handler(CommandHandler("status", status))
    app.run_polling()

if __name__ == "__main__":
    main()
