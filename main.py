from telegram.ext import Application, CommandHandler
import subprocess
import os

REPO_DIR = os.getcwd()
GITHUB_TOKEN = os.environ["GH_TOKEN"]
GITHUB_USERNAME = "Elcapitanoe"

async def mirror(update, context):
    if not context.args:
        await update.message.reply_text("❌ Format:\n/mirror <direct download URL>")
        return

    url = context.args[0]
    await update.message.reply_text(f"🔁 Mirroring: `{url}`", parse_mode="Markdown")

    with open(os.path.join(REPO_DIR, "config.txt"), "w") as f:
        f.write(url)

    subprocess.run("git config user.email 'bot@example.com'", shell=True, cwd=REPO_DIR)
    subprocess.run("git config user.name 'MirrorBot'", shell=True, cwd=REPO_DIR)
    subprocess.run("git add config.txt", shell=True, cwd=REPO_DIR)
    subprocess.run("git commit -m 'auto: mirror new file'", shell=True, cwd=REPO_DIR)
    subprocess.run(f"git push https://{GITHUB_TOKEN}@github.com/{GITHUB_USERNAME}/gdrive-mirror-bot.git", shell=True, cwd=REPO_DIR)

    await update.message.reply_text("✅ Mirror triggered!")

def main():
    BOT_TOKEN = os.environ["BOT_TOKEN"]
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("mirror", mirror))
    app.run_polling()

if __name__ == "__main__":
    main()
