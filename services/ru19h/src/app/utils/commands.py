from utils.scripts import get_poll_desc

async def start(update, context) -> None:
    """Inform user about what this bot can do"""
    await update.message.reply_text(
        "Please select /poll to get a Poll, /quiz to get a Quiz or /preview"
        " to generate a preview for your poll"
    )


async def poll(update, context) -> None:
    """Sends a predefined poll"""
    title, questions = get_poll_desc(context.args)
    message = await context.bot.send_poll(
        update.effective_chat.id,
        title,
        questions,
        is_anonymous=False,
        allows_multiple_answers=True,
    )
    context.bot_data.update(message)


async def help_handler(update, context) -> None:
    """Display a help message"""
    await update.message.reply_text("Use /quiz, /poll or /preview to test this bot.")