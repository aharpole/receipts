class TweetMarkdown
  QUOTE_LEVEL_LIMIT = 7
  class TweetArgumentError < StandardError; end;
  def self.from_tweet(url_or_tweet)
    tweet = case url_or_tweet
    when String then $twitter_client.status(url_or_tweet, tweet_mode: :extended)
    when Twitter::Tweet then url_or_tweet
    else raise TweetArgumentError.new("Expected tweet URL or tweet object, got #{url_or_tweet.class}")
    end
    
    new(tweet: tweet)
  end
  
  attr_reader :tweet, :quote_level
  
  def initialize(tweet:, quote_level:0)
    @tweet = tweet
  end
  
  def h1_tag
    "#" * quote_level + 1
  end
  
  def h2_tag
    "#" * quote_level + 2
  end
  
  def quoted_tweet_markdown_lines
    
  end
  
  def media_markdown_lines
    lines = []
    if tweet.attrs.dig(:extended_entities, :media).any?
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "photo"}.each do |photo|
        url = photo[:url_https]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{photo[:id]}.#{ext}"
        DownloadAssetJob.perform_later(url, path)
        lines << "![](#{path})"
        lines << "<a download='#{photo[:id]}.#{ext}' href='#{photo[:url]}'>Download Original</a>" #TODO: point to Dropbox link
        tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "video"}.each do |video|
          url = video[:video_info][:variants].detect { |variant| variant[:content_type] == "video/mp4"}[:url]
          ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
          path = "assets/media/#{tweet.id}/#{video[:id]}.#{ext}"
          DownloadAssetJob.perform_later(url, path)
          lines << "![](#{path})"
          lines << "<a download='#{video[:id]}.#{ext}' href='#{video[:url]}'>Download Original</a>" #TODO: point to Dropbox link
        end
      end
    end
    lines
  end
  
  def render(quote_level=0)
    lines = []
    lines << "#{h1_tag} @#{tweet.user.screen_name}"
    lines << "#{h2_tag} #{tweet.full_text}"
    lines.concat media_markdown_lines if tweet.media?
    lines.concat quoted_tweet_markdown_lines if tweet.attrs[:is_quote_status]
    if quote_level > 0
      markdown.lines.each { |line| line.prepend(">" * quote_level, " ")}
    end
    markdown
  end
end