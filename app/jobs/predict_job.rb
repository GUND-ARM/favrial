class PredictJob < ApplicationJob
  queue_as :default

  def perform(count = 30)
    perform_predict_for_new_tweets(count)
  end

  def perform_predict_for_new_tweets(count)
    tweets = Tweet.unclassified_with_photo
                  .where(failed_prediction_count: nil)
                  .or(Tweet.where('failed_prediction_count < ?', 3))
                  .order(created_at: :desc).limit(count)
    Rails.logger.info("No more tweets to predict") if tweets.count.zero?
    tweets.each do |tweet|
      perform_predict_tweet(tweet)
    end
  end

  def perform_predict_tweet(tweet)
    tweet.predict
  rescue StandardError => e
    Rails.logger.error("Unexpected error while predict for id: #{tweet.id}, #{e.class}: #{e.message}")
    return nil
  end
end
