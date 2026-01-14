require "ruby_llm"

class LlmSummarizer
  def initialize(events)
    @events = events
  end

  def summary
    prompt = build_prompt(@events)
    chat = RubyLLM.chat(
      provider: :openai,       
      model: 'gpt-4o-mini',   #之後留意語法是否有錯      
      assume_model_exists: true # 加上這個參數是保險做法，強制 gem 接受這個型號
    )
    response = chat.ask(prompt)
    response.content
  end

  private

  def build_prompt(events)
    grouped = events.group_by { |e| e['author']['name'] rescue 'Unknown' }
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