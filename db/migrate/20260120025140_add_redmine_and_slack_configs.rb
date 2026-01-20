class AddRedmineAndSlackConfigs < ActiveRecord::Migration[8.1]
  def change
    # 建立 Redmine Configs
    create_table :redmine_configs do |t|
      t.belongs_to :project, null: false, foreign_key: true # 這會自動加上 FK
      t.string :base_url, null: false
      t.string :api_key, null: false
      # 如果不同專案對應不同的 Redmine Project ID，也可以加在這裡
      t.string :redmine_project_id 
      t.timestamps
    end

    # 建立 Slack Configs
    create_table :slack_configs do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :bot_token, null: false      # 每個專案可能有不同的 Bot (或共用但存這裡)
      t.string :channel_id, null: false     
      t.timestamps
    end

    add_column :gitlab_configs, :gitlab_project_id, :string, comment: "GitLab 遠端專案 ID (例如: 506)"
    remove_column :projects, :slack_channel_id, :string
    remove_column :projects, :gitlab_project_id, :string
  end
end