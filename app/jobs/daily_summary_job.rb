class DailySummaryJob < ApplicationJob
  queue_as :default

  # 當發生 StandardError 時，最多重試 3 次，每次間隔時間會變長
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(project_id)
    
    DailySummaryService.new(project_id: project_id).perform
  end
end