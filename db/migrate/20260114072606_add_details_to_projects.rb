class AddDetailsToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :gitlab_project_id, :string
    add_column :projects, :slack_channel_id, :string
  end
end
