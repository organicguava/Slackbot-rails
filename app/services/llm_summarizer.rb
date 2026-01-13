require "ruby_llm"

class LlmSummarizer
  def initialize(events)
    @events = events
  end

  def summary
    prompt = build_prompt(@events)
    result = RubyLLM.chat(
      model: :gemini_pro,
      messages: [
        { role: "user", content: prompt }
      ]
    )
    result.text
  end

  private

  def build_prompt(events)
    grouped = events.group_by { |e| e['author'] }
    prompt = "請將以下活動紀錄，依 author 分區，集中條列：\n\n"
    grouped.each do |author, acts|
      prompt << "【#{author}】\n"
      acts.each do |e|
        prompt << "- #{e['created_at']} #{e['action_name']} #{e['target_type']}\n"
      end
      prompt << "\n"
    end
    prompt
  end
end