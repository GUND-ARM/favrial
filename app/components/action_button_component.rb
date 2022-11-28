# frozen_string_literal: true

class ActionButtonComponent < ViewComponent::Base
  def initialize(tweet:)
    @tweet = tweet
  end

end
