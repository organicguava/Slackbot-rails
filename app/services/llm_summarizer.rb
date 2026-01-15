require "ruby_llm"

class LlmSummarizer
  # 傳入已經整理好的 Hash 資料
  def initialize(gitlab_data:, redmine_data:)
    @gitlab = gitlab_data
    @redmine = redmine_data
  end

  def perform
    chat = RubyLLM.chat(model: 'gpt-4o-mini')
    
    response = chat
      .with_temperature(0.3)
      .with_instructions(system_prompt) # 設定 System Role
      .ask(user_payload) # 發送 User Message
    
    response.content
  rescue StandardError => e
    Rails.logger.error "LLM Error: #{e.message}"
    "無法產生總結，請檢查 API Key 或 AI 服務狀態。\n錯誤訊息：#{e.message}"
  end

  private

  def build_messages
    [
      { role: 'system', content: system_prompt },
      { role: 'user', content: user_payload }
    ]
  end

  def system_prompt
    <<~PROMPT
      你是一個資深的技術專案經理 (TPM)，負責撰寫「每日專案開發彙報」。
      
      # 核心任務
      請將輸入的「Redmine 規格」與「GitLab 開發動態」結合成一份簡潔的摘要。
      
      # 輸出風格 (Ruby Info Bot 風格)
      請針對每個任務產出以下區塊 (請使用繁體中文)：
      
      1. **Core Focus (核心目標)**: 
         - 結合 Redmine 標題與重點，一句話解釋這張票在做什麼。
      
      2. **Latest Discussion (最新進展/阻礙)**:
         - 分析 GitLab 的 Discussions。
         - 若出現 "SeedTask", "N+1", "Error", "Conflict" 等關鍵字，請明確指出這是「技術阻礙」。
         - 必須指名道姓 (例如: "Yi-Xian 指出...")，這對 PM 判斷責任歸屬很重要。
         - 如果沒有特別討論，請略過此區塊或顯示「無重大討論」。
      
      3. **Current Status (當前狀態)**:
         - 根據 GitLab 的 State (merged/opened) 與 Redmine Status 綜合判斷。
    PROMPT
  end

  def user_payload
    {
      ticket_id: @redmine&.dig(:id) || "Unknown",
      redmine_spec: {
        subject: @redmine&.dig(:subject),
        status: @redmine&.dig(:status),
        summary: @redmine&.dig(:description_summary)
      },
      gitlab_activity: {
        title: @gitlab[:title],
        state: @gitlab[:state],
        discussions: @gitlab[:discussions] # 這是從 Fetcher 清洗過的乾淨對話
      }
    }.to_json
  end
end