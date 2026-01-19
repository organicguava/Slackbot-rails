class Project < ApplicationRecord
    has_one :gitlab_config, dependent: :destroy

    has_many :summary_logs, dependent: :destroy

    # 自動生成 slug
    before_save :generate_slug
end
