class ImportStatus < ApplicationRecord
  enum status: [:created, :importing, :finished, :error, :missing, :forbidden, :media_missing]
  
  def self.next_to_import
    created.order(tweet_id: :asc).first
  end
  
  def self.add_to_imports(tweet_id)
    where(tweet_id: tweet_id).first_or_create
  end
end
