LINE_LIMIT = 10000

namespace :media_urls do
  task :sulemio => :environment do
    Tweet.classified_with_sulemio_photo.order('RANDOM()').limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url
    end
  end

  task :notsulemio => :environment do
    Tweet.classified_with_notsulemio_photo.order('RANDOM()').limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url
    end
  end
end
