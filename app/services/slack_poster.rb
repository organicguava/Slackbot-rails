require 'slack-ruby-client'

class SlackPoster
  def initialize(channel_id, token)
    @channel_id = channel_id
    @token = token
    Slack.configure do |config|
      config.token = @token
    end
    @client = Slack::Web::Client.new
  end

  def post(text)
    # 使用 Block Kit 格式發送，比純文字更專業
    blocks = [
      {
        type: "header",
        text: { type: "plain_text", text: "每日專案進度總結 - #{Date.today}" }
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

    # 會在終端機或 Log 中顯示發送結果
    @client.chat_postMessage(channel: @channel_id, blocks: blocks, text: "本日專案進度摘要已送達")
  rescue Slack::Web::Api::Errors::SlackError => e
    Rails.logger.error "Slack API Error: #{e.message}"
    #  raise error 讓 Job 可以捕捉到錯誤並決定是否重試
    raise e
  end
end