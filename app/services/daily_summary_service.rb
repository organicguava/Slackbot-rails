class DailySummaryService
  def initialize(project_id:, slack_channel_id:)
    @project = Project.find(project_id)
    
    # check:檢查db欄位設置是否有更新
    # 根據 schema.rb，你的 projects table 有 gitlab_project_id 和 slack_channel_id
    @gitlab_project_id = @project.gitlab_project_id
    @slack_channel_id = @project.slack_channel_id
    
    @gitlab_fetcher = DataFetchers::Gitlab.new
    @redmine_fetcher = DataFetchers::Redmine.new
    @slack_poster = SlackPoster.new(@slack_channel_id)
  end

  def perform(force_refresh: false) # 加入參數是為了測試用，因為原本的邏輯是一天只會跑一次

    # 只有在 "非強制" 且 "已存在成功紀錄" 時才跳過
    if !force_refresh && SummaryLog.exists?(project: @project, log_date: Date.current, status: 'success')
        Rails.logger.info "專案 #{@project.name} 今日已完成總結，跳過執行。"
        return
    end

    Rails.logger.info "開始執行專案 #{@project.name} 的每日總結..."


    mrs_list = @gitlab_fetcher.fetch_daily_mrs(@gitlab_project_id)

    if mrs_list.empty?
      # 即使沒有 MR，也建議記錄一筆 'skipped' 或 'no_content'，證明程式有跑過
      create_log(status: 'no_content', content: '無活躍 MR')
      return
    end

    daily_report = mrs_list.map do |mr_stub|
      process_single_mr(mr_stub[:iid])
    end.compact.join("\n\n---\n\n")

    if daily_report.present?
      @slack_poster.post(daily_report)
      
      # 3. 狀態記錄：成功後寫入 Log
      create_log(status: 'success', content: daily_report)
    end
  rescue StandardError => e
    # 4. 錯誤處理：發生預期外的錯誤時，記錄失敗原因，並重新拋出讓 Job Retry
    create_log(status: 'failed', content: "Error: #{e.message}")
    raise e
  
  end

  private

  def process_single_mr(mr_iid)
    # A. 抓取 GitLab 詳細上下文 (包含清洗過的留言)
    gitlab_data = @gitlab_fetcher.fetch_mr_context(@gitlab_project_id, mr_iid)
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

  # 寫入 SummaryLog
  def create_log(status:, content:)
    SummaryLog.create!(
      project: @project,
      log_date: Date.current,
      status: status,
      content: content
    )
  end
end