class FetchTimelineJob < ApplicationJob
  queue_as :default

  def perform(count = 3)
    User.joins(:credential).each do |user|
      Rails.logger.info("Fetching timeline for @#{user.username}")
      begin
        user.fetch_reverse_chronological_timelines(count)
      rescue => e
        Rails.logger.error("Error fetching timeline for @#{user.username}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end

    users = User.joins(:credential)
    access_user = users[rand(users.count)]
    begin
      User.bulk_update_new_users(access_user: access_user)
    rescue => e
      Rails.logger.error("Error fetching users by @#{access_user.username}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
