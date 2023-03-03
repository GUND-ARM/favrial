class PredictJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    Tweet.unclassified_with_photo.order('RANDOM()').limit(count).each do |tweet|
      begin
        tweet.predict
      rescue OpenURI::HTTPError => e
        Rails.logger.error e
      end
    end
  end
end
