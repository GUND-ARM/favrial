class FetchTimelineJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    Tweet.fetch_timeline(count)
  end
end
