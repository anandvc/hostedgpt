class ConversationAi::TokenHandler
  class TokenLimitExceeded < StandardError; end

  MAX_TOKENS = 500

  def initialize(chat)
    @chat = chat
  end

  def raise_if_token_limit_exceeded
    total_count = @chat.notes.pluck(:content).sum { |msg| token_count(msg) } + MAX_TOKENS
    raise TokenLimitExceeded if total_count >= model_token_limit("gpt-3.5-turbo")
  end

  def prepare_messages_for_openai
    @chat.notes.pluck(:content).map { |content| {role: "user", content: content} }
  end

  private

  def token_count(string)
    Tiktoken.encoding_for_model("gpt-3.5-turbo").encode(string).length
  end

  def model_token_limit(name)
    {
      "gpt-4-1106-preview": 128000,
      "gpt-4-vision-preview": 128000,
      "gpt-4": 8192,
      "gpt-4-32k": 32768,
      "gpt-4-0613": 8192,
      "gpt-4-32k-0613": 32768,
      "gpt-3.5-turbo-1106": 16385,
      "gpt-3.5-turbo": 4096,
      "gpt-3.5-turbo-16k": 16385,
      "gpt-3.5-turbo-instruct": 4096
    }[name.to_sym]
  end
end
