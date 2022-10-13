class TweetMarkdown
  QUOTE_LEVEL_LIMIT = 7
  BASE_PATH = "#{Dir.home}/twitter_receipts/"
  URL_REGEX = %r{(?i)\b((?:https?:(?:/{1,3}|[a-z0-9%])|[a-z0-9.\-]+[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)/)(?:[^\s()<>{}\[\]]+|\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\))+(?:\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])|(?:(?<!@)[a-z0-9]+(?:[.\-][a-z0-9]+)*[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)\b/?(?!@)))}
  class TweetArgumentError < StandardError; end;
  def self.from_tweet(url_or_tweet)
    tweet = case url_or_tweet
    when String, Integer then $twitter_client.status(url_or_tweet, tweet_mode: :extended)
    when Twitter::Tweet then url_or_tweet
    else raise TweetArgumentError.new("Expected tweet URL, ID, or tweet object, got #{url_or_tweet.class}")
    end
    
    new(tweet: tweet)
  end
  
  attr_reader :tweet, :quote_level
  
  def initialize(tweet:, quote_level:0)
    @tweet = tweet
    @quote_level = quote_level
  end
  
  def id
    tweet.id
  end
  
  def h1_tag
    "#" * (quote_level + 1)
  end
  
  def h2_tag
    "#" * (quote_level + 2)
  end
  
  def quoted_tweet_markdown_lines
    
  end
  
  def save
    FileUtils.mkdir_p(BASE_PATH)
    file_path = File.join(BASE_PATH, file_name)
    rendered = render
    File.open(file_path, "w") do |file|
      file.write(rendered)
    end
  rescue Errno::ENAMETOOLONG => e
    file_path = File.join(BASE_PATH, alt_file_name)
    File.open(file_path, "w") do |file|
      file.write(rendered)
    end
  end
  
  def file_name
    filename = "@#{tweet.user.screen_name} #{macos_file_name_safe(strip_urls(tweet.full_text))}"[0..230]
    "#{filename} #{tweet.id}.md"
  end
  
  def alt_file_name
    "@#{tweet.user.screen_name} - #{tweet.id}.md"
  end
  
  def strip_urls(str)
    str.gsub(URL_REGEX, "")
  end
  
  def macos_file_name_safe(str)
    str.gsub(":", "\u0589") #armenian colon
    .gsub("/", "⁄")
    .gsub("\n", "⏎")
  end
  
  def media_markdown_lines
    lines = []
    if tweet.attrs.dig(:extended_entities, :media).any?
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "photo"}.each do |photo|
        url = photo[:media_url_https]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{photo[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
        lines << "![](#{path})"
        lines << "<a download='#{photo[:id]}.#{ext}' href='#{photo[:url]}'>Download Original</a>" #TODO: point to Dropbox link
        lines << ""
      end
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "video"}.each do |video|
        url = video[:video_info][:variants].detect { |variant| variant[:content_type] == "video/mp4"}[:url]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{video[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
        lines << "<video src='#{path}' controls />"
        lines << "<a download='#{video[:id]}.#{ext}' href='#{video[:url]}'>Download Original</a>" #TODO: point to Dropbox link
        lines << ""
      end
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "animated_gif"}.each do |gif|
        url = gif[:video_info][:variants].detect { |variant| variant[:content_type] == "video/mp4"}[:url]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{gif[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
        lines << "<video autoplay loop muted playsinline src='#{path}' />"
        lines << "<a download='#{gif[:id]}.#{ext}' href='#{gif[:url]}'>Download Original</a>" #TODO: point to Dropbox link
        lines << ""
      end
    end
    lines
  end
  
  def download_media
    if tweet.attrs.dig(:extended_entities, :media).any?
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "photo"}.each do |photo|
        url = photo[:media_url_https]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{photo[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
      end
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "video"}.each do |video|
        url = video[:video_info][:variants].detect { |variant| variant[:content_type] == "video/mp4"}[:url]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{video[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
      end
      tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "animated_gif"}.each do |gif|
        url = gif[:video_info][:variants].detect { |variant| variant[:content_type] == "video/mp4"}[:url]
        ext = url.split("?").first.split(".").last # this is suboptimal but should get extension and skip the query params
        path = "assets/media/#{tweet.id}/#{gif[:id]}.#{ext}"
        DownloadAssetJob.perform_now(url, path)
      end
    end
  end
  
  def missing_media?
    return false unless tweet.attrs.dig(:extended_entities, :media)&.any?
    tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "video"}.any? ||
    tweet.attrs[:extended_entities][:media].select { |entity| entity[:type] == "animated_gif"}.any?
  end
  
  def check_missing_media!
    if missing_media?
      puts "#{tweet.id} missing media" #we'll manually import these as missing media
    end
    # if tweet.attrs[:is_quote_status]
#       quoted_tweet = $twitter_client.status(tweet.attrs[:quoted_status_id], tweet_mode: :extended)
#       quoted_tweet_md = TweetMarkdown.new(tweet: quoted_tweet, quote_level: quote_level + 1)
#       quoted_tweet_md.check_missing_media!
#     end
  end
  
  def quote_tweet?
    tweet.attrs[:is_quote_status]
  end
  
  def quoted_tweet_id
    tweet.attrs[:quoted_status_id]
  end
  
  def urls
    tweet.attrs[:entities][:urls]
  end
  
  def media_urls
    media = tweet.attrs.dig(:entities, :media) || []
    media.map {|entity| entity[:url]}
  rescue
    binding.pry
  end
  
  def expanded_text
    text = tweet.full_text
    urls.each do |url|
      puts "replacing #{url[:url]} with #{url[:expanded_url]}"
      text = text.gsub(url[:url], url[:expanded_url])
    end
    # the media URLs can go; we're going to render them inline!
    media_urls.each do |url|
      text = text.remove(url)
    end
    text
  end
  
  def render()
    lines = []
    lines << "#{h1_tag} #{tweet.user.name} @#{tweet.user.screen_name}"
    lines << "#{h2_tag} #{expanded_text}"
    lines.concat media_markdown_lines if tweet.media?
    if tweet.attrs[:is_quote_status] && quote_level <= QUOTE_LEVEL_LIMIT
      quoted_tweet = $twitter_client.status(tweet.attrs[:quoted_status_id], tweet_mode: :extended)
      quoted_tweet_md = TweetMarkdown.new(tweet: quoted_tweet, quote_level: quote_level + 1)
      lines.concat quoted_tweet_md.render.lines
      lines << ""
    end
    Time.use_zone "Pacific Time (US & Canada)" do
      timestamp = Time.parse(tweet.attrs[:created_at])
      time_str = timestamp.strftime("%B %-d, %Y %l (Pacific)")
      lines << "[#{time_str}](#{tweet.url}) - #{tweet.source}"
    end
    if quote_level > 0
      lines.each { |line| line.prepend(">" * quote_level, " ")}
    end
    lines.join("\n")
  end
end