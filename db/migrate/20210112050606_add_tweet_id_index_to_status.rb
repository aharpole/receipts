class AddTweetIdIndexToStatus < ActiveRecord::Migration[6.0]
  def change
    add_index :import_statuses, :tweet_id
  end
end
