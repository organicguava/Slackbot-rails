# 抓取MR及對話
module DataFetchers
  class Gitlab
    # 定義 API 版本
    API_BASE = 'api/v4'.freeze

    def initialize(base_url:, token:)
      @base_url = base_url
      @token = token
      
      @client = Faraday.new(url: @base_url) do |f|
        f.headers['PRIVATE-TOKEN'] = @token
        f.adapter Faraday.default_adapter
      end
    end

    # 主要功能：抓取 MR 及其討論串
    # project_id: 506, mr_iid: 1 (注意是 IID)
    def fetch_mr_context(project_id, mr_iid)
      # 1. 抓取 MR 本體資訊
      mr_raw = get_json("#{API_BASE}/projects/#{project_id}/merge_requests/#{mr_iid}")
      
      # 2. 抓取 MR 留言 (Notes)
      notes_raw = get_json("#{API_BASE}/projects/#{project_id}/merge_requests/#{mr_iid}/notes?sort=asc")

      # 3. 進行 Inline Cleaning (行內清洗)
      {
        source: 'gitlab',
        id: mr_raw['iid'],
        title: mr_raw['title'],
        description: mr_raw['description'], # 用於稍後解析 Redmine Ticket ID
        state: mr_raw['state'],
        web_url: mr_raw['web_url'],
        # 過濾 system: true 的雜訊，只保留人類對話
        discussions: clean_discussions(notes_raw)
      }
    rescue Faraday::Error => e
      Rails.logger.error "GitLab API Error: #{e.message}"
      nil
    end


    # 抓取過去 24 小時有更新的 MR 列表
    def fetch_daily_mrs(project_id)
      # created_after: 新建立的, updated_after: 有新動態的
      # state: opened (只關心進行中的) 或 all (看需求)
      params = {
        scope: 'all',
        state: 'opened',
        updated_after: 1.day.ago.iso8601,
        per_page: 20
      }
      
      # 這裡只需要抓簡易列表，拿到 IID 即可
      results = get_json("#{API_BASE}/projects/#{project_id}/merge_requests?#{params.to_query}")
      
      # 只回傳需要的 IID 與 Title 供初步篩選
      results.map { |mr| { iid: mr['iid'], title: mr['title'] } }
    rescue Faraday::Error => e
      Rails.logger.error "GitLab Fetch List Error: #{e.message}"
      []

    end

    private

    def get_json(path)
      response = @client.get(path)
      unless response.success?
        raise Faraday::Error, "GitLab Request Failed: #{response.status} #{response.body}"
      end
      JSON.parse(response.body)
    end

    def clean_discussions(notes)
      notes.select { |n| n['system'] == false }.map do |n|
        {
          user: n['author']['name'],
          body: n['body'],
          created_at: n['created_at']
        }
      end
    end



  end
end