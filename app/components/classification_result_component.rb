# frozen_string_literal: true

class ClassificationResultComponent < ViewComponent::Base
  def initialize(tweet)
    @tweet = tweet
  end
end
