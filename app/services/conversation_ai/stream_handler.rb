class ConversationAi::StreamHandler
  def initialize(reply)
    @reply = reply
  end

  def handle_stream
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      finish_reason = chunk.dig("choices", 0, "finish_reason")

      new_content = format_content(@reply, new_content)

      if new_content.present?
        @reply.content += new_content
        @reply.broadcast_updated(new_content)
      end

      @reply.save! if finish_reason.present?
    end
  end

  private

  def format_content(new_content)
    return new_content unless @reply.content.present? && new_content.present?
    return new_content if @reply.content[-1].match?(/\d/) && new_content[0].match?(/\d/)
    return " " + new_content unless new_content[0].match?(/\d/)
    new_content
  end
end
