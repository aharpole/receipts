desc 'imports the tweets in the given file passed in as an argument'
task import_from_file: :environment do
  # silly hack to let us use ARGV
  ARGV.each { |a| task a.to_sym do ; end }
  
  path = ARGV[1]
  puts "opening file #{path}"
  processed_tweets = ""
  File.open(path).each do |url|
    # http://twitter.com/tef_ebooks/status/1350959192492941319
    tweet_id = url.split("/").last
    ImportStatus.add_to_imports(tweet_id)
    processed_tweets << "#{url}\n"
  end
  status = nil
  while status != :no_more
    status = ImportTweet.perform_now
  end
  directory = File.dirname(path)
  processed_path = File.join(directory, "processed.txt")
  FileUtils.touch(processed_path)
  File.write(processed_path, processed_tweets, File.size(processed_path), mode: 'a')
  FileUtils.rm(path)
  # FileUtils.mv(path, processed_path)
  puts "done importing tweets from file"
  next 0
end