$twitter_client = Twitter::REST::Client.new do |c|
  c.consumer_key = Rails.application.credentials.twitter[:consumer_key]
  c.consumer_secret = Rails.application.credentials.twitter[:consumer_secret]
  c.access_token = Rails.application.credentials.twitter[:access_token]
  c.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
end