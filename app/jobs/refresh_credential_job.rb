class RefreshCredentialJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.joins(:credential).each do |user|
      credential = user.credential
      if credential.expired?
        credential.refresh
        Rails.logger.info "Refreshed credential for user id: #{user.id} username: #{user.username}"
      end
    end
  end
end
