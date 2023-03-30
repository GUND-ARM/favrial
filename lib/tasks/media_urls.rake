DEFAULT_LINE_LIMIT = 10000

namespace :media_urls do
  task :sulemio => :environment do
    line_limit = ENV.fetch('MEDIA_URLS_LINE_LIMIT', DEFAULT_LINE_LIMIT).to_i
    warn "line_limit: #{line_limit}"
    Tweet.classified_with_sulemio_photo.order('RANDOM()').limit(line_limit).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url && tweet.media_count == 1
    end
  end

  task :notsulemio => :environment do
    line_limit = ENV.fetch('MEDIA_URLS_LINE_LIMIT', DEFAULT_LINE_LIMIT).to_i
    warn "line_limit: #{line_limit}"
    Tweet.classified_with_notsulemio_photo.order('RANDOM()').limit(line_limit).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url && tweet.media_count == 1
    end
  end
end
