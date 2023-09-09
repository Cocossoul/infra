from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes
from utils.scripts import get_token
from utils.commands import start, poll, help_handler

TOKEN = get_token()


def main():
    """Run bot."""
    # Create the Application and pass it your bot's token.
    application = Application.builder().token(TOKEN).build()
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("ru", poll))
    application.add_handler(CommandHandler("help", help_handler))

    # Run the bot until the user presses Ctrl-C
    application.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
