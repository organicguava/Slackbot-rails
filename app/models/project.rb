class Project < ApplicationRecord
    has_one :gitlab_config, dependent: :destroy
end
