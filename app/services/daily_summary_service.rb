class DailySummaryService
  def initialize(project_id:, slack_channel_id:)
    @project_id = project_id
    @slack_channel_id = slack_channel_id
    
    @gitlab_fetcher = DataFetchers::Gitlab.new
    @redmine_fetcher = DataFetchers::Redmine.new
    @slack_poster = SlackPoster.new(slack_channel_id)
  end

  def perform
    # 找出今日有變動的 MR
    mrs_list = @gitlab_fetcher.fetch_daily_mrs(@project_id)

    if mrs_list.empty?
      Rails.logger.info "專案 #{@project_id} 今日無活躍 MR，跳過總結。"
      return
    end

    # 逐一處理每個 MR 
    daily_report = mrs_list.map do |mr_stub|
      process_single_mr(mr_stub[:iid])
    end.compact.join("\n\n---\n\n") # 用分隔線串接多個總結

    # 發送到 Slack
    if daily_report.present?
      @slack_poster.post(daily_report)
    end
  end

  private

  def process_single_mr(mr_iid)
    # A. 抓取 GitLab 詳細上下文 (包含清洗過的留言)
    gitlab_data = @gitlab_fetcher.fetch_mr_context(@project_id, mr_iid)
    return nil unless gitlab_data

    # B. 嘗試連結 Redmine (Entity Linking)
    ticket_id = extract_ticket_id(gitlab_data[:title])
    
    # C. 抓取 Redmine 規格 (如果有票號)
    redmine_data = ticket_id ? @redmine_fetcher.fetch_issue(ticket_id) : nil

    # D. 呼叫 AI 產生內文
    ai_summary = LlmSummarizer.new(gitlab_data: gitlab_data, redmine_data: redmine_data).perform

    # E. 組合標題與內文 (Slack Link 格式: <URL|Text>)
    # 每段總結最上面就會有清楚的標題連結
    header = "*<#{gitlab_data[:web_url]}|[MR !#{gitlab_data[:id]}] #{gitlab_data[:title]}>*"
    
    "#{header}\n#{ai_summary}"
  end

  # 慣例：從標題提取票號
  def extract_ticket_id(title)
    title.scan(/#(\d+)/).flatten.first
  end
end