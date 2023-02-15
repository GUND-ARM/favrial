class FetchTimelineJob < ApplicationJob
  queue_as :default

  def perform(count = 10)
    User.all.each do |user|
      if user.credential.nil?
        Rails.logger.info("Skipping @#{user.username} because they have no credentials")
        next
      end

      Rails.logger.info("Fetching timeline for @#{user.username}")
      begin
        user.fetch_reverse_chronological_timelines(count)
      rescue => e
        Rails.logger.error("Error fetching timeline for @#{user.username}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  end
end
