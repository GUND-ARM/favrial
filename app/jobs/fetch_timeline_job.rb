class FetchTimelineJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    Tweet.import_timelines(count)
  end
end
