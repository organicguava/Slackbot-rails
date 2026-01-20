# db/seeds.rb

puts "開始初始化專案資料..."

# 建立主專案 (Project)
project = Project.find_or_create_by!(name: "Main App") do |p|
  p.active = true
end
puts "專案 #{project.name} 已就緒"

# 建立 GitLab 設定 (GitlabConfig)
GitlabConfig.find_or_create_by!(project: project) do |c|
  c.base_url     = Rails.application.credentials.dig(:gitlab, :base_url)
  c.access_token = Rails.application.credentials.dig(:gitlab, :access_token)
  c.gitlab_project_id = "464" 
end
puts "   - GitLab 設定已建立"

# 建立 Slack 設定
SlackConfig.find_or_create_by!(project: project) do |c|
    c.bot_token  = Rails.application.credentials.dig(:slack, :bot_token)
    c.channel_id = "C0A7LG5DGDN" 
end
puts "   - Slack 設定已建立"

# 建立 Redmine 設定
RedmineConfig.find_or_create_by!(project: project) do |c|
  c.base_url = Rails.application.credentials.dig(:redmine, :base_url)
  c.api_key  = Rails.application.credentials.dig(:redmine, :api_key)
  # 如果你有 Redmine 的專案 ID，也可以加在這裡，目前 schema 允許為空

end
puts "   - Redmine 設定已建立"

puts "資料初始化完成！請執行 rails c 驗證。"