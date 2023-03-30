LINE_LIMIT = ENV.fetch('MEDIA_URLS_LINE_LIMIT', 10000).to_i

# LINE_LIMIT を標準エラー出力に出す
warn "LINE_LIMIT: #{LINE_LIMIT}"

namespace :media_urls do
  task :sulemio => :environment do
    Tweet.classified_with_sulemio_photo.order('RANDOM()').limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url && tweet.media_count == 1
    end
  end

  task :notsulemio => :environment do
    Tweet.classified_with_notsulemio_photo.order('RANDOM()').limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url && tweet.media_count == 1
    end
  end
end
