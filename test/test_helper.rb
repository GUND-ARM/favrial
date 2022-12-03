ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def auth_hash
    h = {
      "provider" => "twitter2",
      "uid" => "1585913733750042624",
      "info" => {
        "name" => "🦝🍅の絵をふぁぼる",
        "email" => nil,
        "nickname" => "witchandtrophy",
        "description" => "スレミオの絵をふぁぼる/スレミオ決闘委員会（仮）/創作イタリアンカフェ地球寮/スレミオ社会構成主義/フロント探検隊/うるさいオタクです遠慮なく引用RTしてください/リコリコ関連はこっち→ @recoryco",
        "image" => "https://pbs.twimg.com/profile_images/1587357812614516737/G0LrRMe7_normal.jpg",
        "urls" => {
          "Website" => "https://t.co/e8lk5j66Ch",
          "Twitter" => "https://twitter.com/witchandtrophy"
        }
      },
      "credentials" => {
        "token" => "eENmbUxvbnk5SnlxcGhacHdZbXNYT1FidVlJTXZDaHZUSGNyaDE0dmFQZGlrOjE2Njk5ODk2MzI5NjM6MToxOmF0OjE",
        "refresh_token" => "cFJFdTctbGFOUHdGSmx4VUpUdmxnZGJWZGJPT1djZWdxbHJUT0x2RkE0eE5yOjE2Njk5OTY4MDM4NTA6MToxxxxxxxx",
        "expires_at" => 1669996833,
        "expires" => true
      }
    }.freeze
    ActiveSupport::HashWithIndifferentAccess.new(h)
  end
end
