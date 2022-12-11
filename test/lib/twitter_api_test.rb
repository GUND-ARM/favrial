require "test_helper"

class TwitterAPITest < ActiveSupport::TestCase
  test "APIレスポンスのJSONからRT以外のツィートを抽出できる" do
    op = TwitterAPI::ResponseOperator.new(timeline_api_response)
    types = op.bare_tweets.map { |t| t["referenced_tweets"] }.select { |t| t }.map { |t| t[0]["type"] }
    assert_not types.uniq.include?("retweeted")
  end

  test "media_keyが一致するメディアの一覧を抽出できる" do
    op = TwitterAPI::ResponseOperator.new(timeline_api_response)
    medias = op.medias_for_tweet(tweet_hash_with_media)
    match = (medias in [ { media_key: "3_1600535519317745664", type: "photo" } ])
    assert match
  end
end
