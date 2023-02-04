class FetchTimelineJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    User.all.each do |user|
      user.fetch_reverse_chronological_timelines(count)
    end
  end
end
