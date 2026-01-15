require 'faraday'
require 'json'

class GitlabClient
  def initialize(base_url:, access_token:)

    @client = Gitlab.client(
      endpoint: "#{base_url}/api/v4", # gem 需要加上 /api/v4
      private_token: access_token
    )


  end

  

  def fetch_events(project_id, params = {})
    # 使用 gem 的方法
    # auto_paginate: true 會自動幫你翻頁抓取所有資料
    events = @client.project_events(project_id, params)

    
    # gem 回傳的是 ObjectifiedHash，轉成純 Hash 比較好跟後面的 Service 相容
    events.map(&:to_h) 
    rescue Gitlab::Error::Error => e
      # 統一捕捉 gem 的錯誤並拋出，方便 Job 紀錄
      raise "Gitlab API Error: #{e.message}. Request URI: #{@client.endpoint}/projects/#{project_id}/events"
    end

end