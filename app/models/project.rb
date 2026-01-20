class Project < ApplicationRecord
    has_one :gitlab_config, dependent: :destroy
    has_one :redmine_config, dependent: :destroy
    has_one :slack_config, dependent: :destroy
    has_many :summary_logs, dependent: :destroy

    # 自動生成 slug
    before_save :generate_slug


    private 

    def generate_slug
        return if self.slug.present? || self.name.blank?

        # 將 name 轉成 url-friendly 格式 (例如 "Main App" -> "main-app")
        self.slug = self.name.parameterize
  end
end
