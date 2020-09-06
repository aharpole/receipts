class DownloadAssetJob < ApplicationJob
  BASE_PATH = "#{Dir.home}/Dropbox/twitter_receipts/"
  def perform(url, path)
    dir = File.join(BASE_PATH, path.split("/")[0..-1].join("/"))
    FileUtils.mkdir_p(dir)
    file_path = File.join(dir, path.split("/").last)
    return if File.exist?(file_path)
    File.open(file_path, "w") do |file|
      response = HTTParty.get(url, stream_body: true) do |fragment|
        if [301, 302].include?(fragment.code)
          print "skip writing for redirect"
        elsif fragment.code == 200
          file.write(fragment)
        else
          raise StandardError, "Non-success status code while streaming #{fragment.code}"
        end
      end
    end
    File.unlink(filename)
  end
end