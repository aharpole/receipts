require 'net/http'

class DownloadAssetJob < ApplicationJob
  class FileFailedToDownload < StandardError; end;
  retry_on FileFailedToDownload, wait: 3.seconds, attempts: 10
  BASE_PATH = "#{Dir.home}/twitter_receipts/"
  def perform(url, path)
    puts "path: #{path}"
    enclosing_folder = path.split("/")[0..-2]
    file_name = path.split("/").last
    dir = File.join(BASE_PATH, *enclosing_folder)
    puts "dir: #{dir}"
    FileUtils.mkdir_p(dir)
    file_path = File.join(dir, file_name)
    puts "file_path: #{file_path}"
    return if File.exist?(file_path) && File.size(file_path) > 0
    File.open(file_path, "wb") do |file|
      response = HTTParty.get(url, follow_redirects: true)
      if response.code == 200
        file.write(response.body)
      else
        logger = Logger.new(Rails.root.join('log','file_download.log'))
        logger.fatal(response_code: response.code, url: url, path: path)
      end
    end
    if File.size(file_path) == 0
      raise FileFailedToDownload
    end
  end
end