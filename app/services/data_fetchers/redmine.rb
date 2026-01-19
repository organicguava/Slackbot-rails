module DataFetchers
  class Redmine
    def initialize
      @base_url = Rails.application.credentials.dig(:redmine, :base_url) || "https://redmine.5xruby.com"
      @api_key = Rails.application.credentials.dig(:redmine, :api_key)

      @client = Faraday.new(url: @base_url) do |f|
        f.headers['X-Redmine-API-Key'] = @api_key
        f.adapter Faraday.default_adapter
      end
    end

    # 抓取票號詳情
    def fetch_issue(ticket_id)
      # 去除可能存在的 # 符號
      clean_id = ticket_id.to_s.delete('#')
      
      response = @client.get("/issues/#{clean_id}.json")
      return nil unless response.success?

      data = JSON.parse(response.body)['issue']
      
      # 根據手冊只取標題與描述
      {
        id: data['id'],
        subject: data['subject'],
        status: data['status']['name'],
        # 簡單擷取前 10 行描述，避免 Token 爆炸
        description_summary: data['description'].to_s.lines.first(10).join
      }
    rescue Faraday::Error => e
      Rails.logger.error "Redmine API Error: #{e.message}"
      nil
    end
  end
end