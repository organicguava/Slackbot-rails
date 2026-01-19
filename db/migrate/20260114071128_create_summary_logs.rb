class CreateSummaryLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :summary_logs do |t|
      t.references :project, null: false, foreign_key: true
      t.text :content
      t.date :log_date
      t.string :status

      t.timestamps
    end
  end
end
