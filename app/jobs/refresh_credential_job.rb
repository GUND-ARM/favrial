class RefreshCredentialJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.all.each do |user|
      credential = user.credential
      if credential.expired?
        credential.refresh
        Rails.logger.info "Refreshed credential for user id: #{user.id} name: #{user.name}"
      end
    end
  end
end
