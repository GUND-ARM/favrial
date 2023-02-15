class RefreshCredentialJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.all.each do |user|
      if user.credential.nil?
        Rails.logger.info "Skipping user id: #{user.id} username: #{user.username} because they have no credential"
        next
      end

      credential = user.credential
      if credential.expired?
        credential.refresh
        Rails.logger.info "Refreshed credential for user id: #{user.id} username: #{user.username}"
      end
    end
  end
end
