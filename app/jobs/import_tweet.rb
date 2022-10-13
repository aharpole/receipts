# takes a tweet that's been added to the import_statuses table as new, processes it, and marks as complete
class ImportTweet < ApplicationJob
  def perform
    import = ImportStatus.next_to_import
    return :no_more unless import
    puts "Processing tweet #{import.tweet_id}"
    import.importing!
    puts "importing!"
    TweetMarkdown.from_tweet(import.tweet_id).save
    puts "saved"
    # import.update_attributes(status: :finished)
    puts "finished!"
    return :done
  rescue Twitter::Error::Forbidden, Twitter::Error::Unauthorized => forbidden
    import.forbidden!
    puts "Marking #{import.tweet_id} as forbidden"
  rescue Twitter::Error::NotFound => missing
    import.missing!
    puts "Marking #{import.tweet_id} as missing"
  rescue => e
    import.error!
    puts "Error processing #{import.tweet_id}: #{e.class}"
    puts "#{e.message}"
    puts "---"
  end
end