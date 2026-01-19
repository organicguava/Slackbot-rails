class DailySummaryJob < ApplicationJob
  queue_as :default

  def perform
    # MVP 階段：參數暫時寫死或讀取環境變數
    # 之後 會改成 Project.where(active: true).each do ...
    
    
    target_project_id = 464 # vivo
    target_channel_id = 'C0A7LG5DGDN' # workflow-refinement

    Rails.logger.info "開始執行每日總結 Job..."
    
    DailySummaryService.new(
      project_id: target_project_id,
      slack_channel_id: target_channel_id
    ).perform
    
    Rails.logger.info "每日總結 Job 執行完畢。"
  end
end