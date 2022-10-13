class FetchRecentTweets < ApplicationJob
  def perform
    count = 200
    max_id = 1341421277454725120
    request_count = 0
    last_id_fetched = nil
    done = false
    while !done && request_count < 75
      options = {}
      options[:count] = count
      max_id && options[:max_id] = max_id
      favs = $twitter_client.favorites(options)
      favs.each do |tweet|
        last_id_fetched = tweet.id
        ImportStatus.add_to_imports(tweet.id)
        puts "Imported tweet #{tweet.id}"
        max_id = tweet.id
      end
      request_count += 1
      puts "request_count: #{request_count}"
    end
    
    puts "Hit max request count at #{last_id_fetched}" if request_count >= 75
  rescue Twitter::Error::TooManyRequests
    puts "Hit rate limit after processing #{max_id}"
  end
end