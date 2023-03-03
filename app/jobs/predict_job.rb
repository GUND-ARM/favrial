class PredictJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    Tweet.unclassified_with_photo.limit(count).each(&:predict)
  end
end
