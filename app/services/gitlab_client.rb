require 'faraday'
require 'json'

class GitlabClient
  def initialize(base_url:, access_token:)
    @base_url = base_url
    @access_token = access_token
    @conn = Faraday.new(url: @base_url) do |f|
      f.request :authorization, 'Bearer', @access_token
      f.adapter Faraday.default_adapter
    end
  end

  # 取得指定 project 的 events
  def fetch_events(project_id, params = {})
    response = @conn.get("/api/v4/projects/#{project_id}/events", params)
    raise "GitLab API error: #{response.status}" unless response.success?
    JSON.parse(response.body)
  end


end