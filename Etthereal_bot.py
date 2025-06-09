from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update, InputMediaPhoto
from telegram.ext import (
    Updater,
    CommandHandler,
    CallbackQueryHandler,
    MessageHandler,
    Filters,
    CallbackContext,
)
import logging

# Bot credentials
BOT_TOKEN = "7603606508:AAHACwLH7BtDb5UUz-ifwTxeSWBZGlCwGOw"
ADMIN_ID = 5646269450

# Enable logging
logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
logger = logging.getLogger(__name__)

# In-memory storage
user_state = {}

# Country payment info
country_accounts = {
    "Nigeria": "🇳🇬 Account: 1234567890\nBank: Zenith Bank\nName: Ethereal Nig Ltd",
    "Ghana": "🇬🇭 Momo: 0551234567\nName: Ethereal Ghana Ltd",
    "United States": "🇺🇸 Zelle: etherealus@example.com",
    "Kenya": "🇰🇪 Mpesa: 0712345678\nName: Ethereal KE",
    "South Africa": "🇿🇦 Capitec: 123456789\nName: Ethereal SA",
    "UK": "🇬🇧 Monzo: etherealuk@example.com",
}

# Start command
def start(update: Update, context: CallbackContext) -> None:
    keyboard = [[InlineKeyboardButton("🚀 Start", callback_data="menu")]]
    update.message.reply_text(
        "**Welcome to Ethereal!**\n\nA premium gateway to your digital experience. Click below to get started.",
        parse_mode="Markdown",
        reply_markup=InlineKeyboardMarkup(keyboard),
    )

# Main menu
def menu(update: Update, context: CallbackContext) -> None:
    keyboard = [
        [InlineKeyboardButton("💸 Register & Make Payment", callback_data="select_country")],
        [InlineKeyboardButton("❓ Help", callback_data="help")],
    ]
    query = update.callback_query
    query.answer()
    query.edit_message_text("Select an option below:", reply_markup=InlineKeyboardMarkup(keyboard))

# Country selector
def select_country(update: Update, context: CallbackContext) -> None:
    keyboard = [
        [InlineKeyboardButton(c, callback_data=f"country_{c}")] for c in country_accounts.keys()
    ]
    keyboard.append([InlineKeyboardButton("🔙 Back", callback_data="menu")])
    query = update.callback_query
    query.answer()
    query.edit_message_text("🌍 Please select your country for payment:", reply_markup=InlineKeyboardMarkup(keyboard))

# Display account info
def show_payment_info(update: Update, context: CallbackContext) -> None:
    country = update.callback_query.data.split("_")[1]
    chat_id = update.effective_chat.id
    user_state[chat_id] = {"country": country}
    context.bot.send_message(
        chat_id=chat_id,
        text=f"💳 Payment details for *{country}*:\n\n{country_accounts[country]}\n\n"
             "Please make the payment and send a *screenshot of your payment confirmation*.",
        parse_mode="Markdown",
    )

# Handle image uploads (screenshot of payment)
def handle_photo(update: Update, context: CallbackContext) -> None:
    chat_id = update.message.chat_id
    if chat_id not in user_state or "country" not in user_state[chat_id]:
        return update.message.reply_text("❌ Please start by selecting your country first.")

    photo_file = update.message.photo[-1].file_id
    context.bot.send_photo(chat_id=ADMIN_ID, photo=photo_file,
                           caption=f"📥 Payment Screenshot Received from @{update.message.from_user.username or 'NoUsername'}\nUserID: {chat_id}")
    context.bot.send_message(chat_id, "✅ Screenshot received!\n\n📌 Please now *send your registration details* in the following format:\n\n"
                                      "`Email address`\n`Full name`\n`Username`\n`Phone number`",
                             parse_mode="Markdown")
    user_state[chat_id]["screenshot"] = True

# Collect user details
def handle_text(update: Update, context: CallbackContext) -> None:
    chat_id = update.message.chat_id
    if chat_id not in user_state or "screenshot" not in user_state[chat_id]:
        return update.message.reply_text("❌ Please send your payment screenshot first.")

    # Forward details to admin
    context.bot.send_message(
        ADMIN_ID,
        f"📝 New Registration Details from @{update.message.from_user.username or 'NoUsername'} (ID: {chat_id}):\n\n{update.message.text}"
    )

    # Send user next step
    update.message.reply_text("🎉 Registration successful!\nYour page will be ready soon.\n\n📌 Meanwhile, join the group below while you wait:\n"
                              "[Join Group](https://t.me/ethereal_group)", parse_mode="Markdown", disable_web_page_preview=True)

# Help menu
def help_menu(update: Update, context: CallbackContext) -> None:
    keyboard = [[InlineKeyboardButton("🔙 Back", callback_data="menu")]]
    help_text = (
        "📖 *Need Help?*\n\n"
        "We offer simple guides to walk you through:\n"
        "- How to register\n"
        "- How to upload payment\n"
        "- How to submit details\n\n"
        "🎥 Video tutorials and PDF guides coming soon!"
    )
    query = update.callback_query
    query.answer()
    query.edit_message_text(help_text, parse_mode="Markdown", reply_markup=InlineKeyboardMarkup(keyboard))

# Callback query handler
def button_handler(update: Update, context: CallbackContext) -> None:
    data = update.callback_query.data
    if data == "menu":
        menu(update, context)
    elif data == "select_country":
        select_country(update, context)
    elif data.startswith("country_"):
        show_payment_info(update, context)
    elif data == "help":
        help_menu(update, context)

# Main entry point
def main() -> None:
    updater = Updater(BOT_TOKEN, use_context=True)
    dp = updater.dispatcher

    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CallbackQueryHandler(button_handler))
    dp.add_handler(MessageHandler(Filters.photo, handle_photo))
    dp.add_handler(MessageHandler(Filters.text & ~Filters.command, handle_text))

    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()