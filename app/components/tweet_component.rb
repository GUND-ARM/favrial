# frozen_string_literal: true

class TweetComponent < ViewComponent::Base
  def initialize(tweet)
    @tweet = tweet
    @name = 'Hakunaru'
    @username = 'shiinakojima'
  end
end
