class Project < ApplicationRecord
    has_one :gitlab_config, dependent: :destroy

    has_many :summary_logs, dependent: :destroy
end
