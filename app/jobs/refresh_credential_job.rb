class RefreshCredentialJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.joins(:credential).each do |user|
      begin
        refresh_user_credential(user)
      rescue => e
        Rails.logger.error("Error refreshing credential for @#{user.username}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  end

  def refresh_user_credential(user)
    credential = user.credential
    if credential.expired?
      credential.refresh
      Rails.logger.info "Refreshed credential for user id: #{user.id} username: #{user.username}"
    else
      Rails.logger.info "Credential for user id: #{user.id} username: #{user.username} is not expired"
    end
  end
end
