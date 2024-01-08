class ConversationAi
  RESPONSES_PER_NOTE = 1
  MAX_RETRIES = 1

  def initialize(user, note)
    @user = user
    @note = note
    @chat = note.chat
    @client = OpenAI::Client.new(access_token: @user.openai_key)
    @token_handler = TokenHandler.new(@chat)
  end

  def process_note
    @token_handler.raise_if_token_limit_exceeded
    replies = create_replies
    chat_parameters = build_chat_parameters(replies)
    process_chat(chat_parameters)
    replies
  end

  private

  def create_replies
    Array.new(RESPONSES_PER_NOTE) { @note.replies.create!(content: "") }
  end

  def build_chat_parameters(replies)
    {
      model: "gpt-3.5-turbo",
      messages: @token_handler.prepare_messages_for_openai,
      temperature: 0.8,
      stream: StreamHandler.new(replies).handle_stream,
      n: RESPONSES_PER_NOTE
    }
  end

  def process_chat(parameters)
    @client.chat(parameters: parameters)
  end
end
