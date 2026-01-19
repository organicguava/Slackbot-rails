class CreateGitlabConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :gitlab_configs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :base_url
      t.string :access_token

      t.timestamps
    end
  end
end
