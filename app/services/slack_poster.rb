require 'slack-ruby-client'

class SlackPoster
  def initialize(channel_id)
    @channel_id = channel_id
    # 從 credentials 讀取 Token
    @client = Slack::Web::Client.new(token: Rails.application.credentials.slack[:bot_token])
  end

  def post(text)
    # 使用 Block Kit 格式發送，比純文字更專業
    blocks = [
      {
        type: "header",
        text: { type: "plain_text", text: "📅 每日專案進度總結 - #{Date.today}" }
      },
      {
        type: "section",
        text: { type: "mrkdwn", text: text }
      },
      {
        type: "context",
        elements: [
          { type: "mrkdwn", text: "由 Rails SlackBot 自動生成 • #{Time.current.strftime('%H:%M')}" }
        ]
      }
    ]

    # text 參數是給通知預覽用的 (Fallback)
    @client.chat_postMessage(channel: @channel_id, blocks: blocks, text: "本日專案進度摘要已送達")
  rescue Slack::Web::Api::Errors::SlackError => e
    Rails.logger.error "Slack API Error: #{e.message}"
    # 這裡可以選擇是否要 raise error 讓 Job 重試，目前先記錄 Log
  end
end