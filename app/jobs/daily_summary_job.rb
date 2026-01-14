class DailySummaryJob < ApplicationJob
  queue_as :default

  def perform
    # 1. 遍歷所有啟用的專案
    Project.where(active: true).each do |project|
      # 2. 抓取 GitLab 資料 (從 credentials 讀取設定)
      config = project.gitlab_config
      client = GitlabClient.new(base_url: config.base_url, access_token: config.access_token)
      events = client.fetch_events(project.gitlab_project_id, { after: 1.day.ago.to_s })

      next if events.empty?

      # 3. 呼叫 OpenAI 進行總結
      summary_content = LlmSummarizer.new(events).summary

      # 4. 存入 SummaryLog 
      project.summary_logs.create!(
        content: summary_content,
        log_date: Date.today,
        status: "success"
      )

      # 5. 推送到 Slack
      SlackPoster.new(project.slack_channel_id).post(summary_content) # channel id ? 
    end
  rescue => e
    # 這裡可以加入錯誤處理，例如紀錄失敗狀態到 SummaryLog
    Rails.logger.error "DailySummaryJob 執行失敗: #{e.message}"
  end
end