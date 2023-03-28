class PredictJob < ApplicationJob
  queue_as :default

  def perform(count = 30)
    Tweet.unclassified_with_photo.order('RANDOM()').limit(count).each do |tweet|
      begin
        tweet.predict
      rescue OpenURI::HTTPError => e
        Rails.logger.error("Error predicting for id: #{tweet.id}: #{e.message}")
        #Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  end
end
