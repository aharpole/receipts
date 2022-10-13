class CreateImportStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :import_statuses do |t|
      t.integer :tweet_id
      t.integer :status

      t.timestamps
    end
  end
end
