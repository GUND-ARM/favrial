LINE_LIMIT = 3000

namespace :media_urls do
  task :sulemio => :environment do
    Tweet.classified_with_photo(Tweet::Classification::SULEMIO).limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url
    end
  end

  task :notsulemio => :environment do
    Tweet.classified_with_photo(Tweet::Classification::NOTSULEMIO).limit(LINE_LIMIT).each do |tweet|
      puts tweet.first_media_url if tweet.first_media_url
    end
  end
end
