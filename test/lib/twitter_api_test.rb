require "test_helper"

class TwitterAPITest < ActiveSupport::TestCase
  test "APIレスポンスのJSONからRT以外のツィートを抽出できる" do
    response = TwitterAPI::TweetsResponse.new(reverse_chronological_response)
    types = response.bare_tweets.map { |t| t["referenced_tweets"] }.select { |t| t }.map { |t| t[0]["type"] }
    assert_not types.uniq.include?("retweeted")
  end

  #test "media_keyが一致するメディアの一覧を抽出できる" do
  #  response = TwitterAPI::TweetsResponse.new(raw_reverse_chronological_response)
  #  medias = response.medias_for_tweet(tweet_hash_with_media)
  #  match = (medias in [ { media_key: "3_1600535519317745664", type: "photo" } ])
  #  assert match
  #end

  test "アタッチメント付きのツィートの1番目のメディアURLを取得できる" do
    response = TwitterAPI::TweetsResponse.new(reverse_chronological_response)
    tweet = response.bare_tweets.select { |t| t[:attachments] }[0]
    assert_equal "1604509826498691073", tweet[:id]
    assert_equal "https://pbs.twimg.com/media/FkRdIYgUYAE5q9N.jpg", response.first_media_url_for_tweet(tweet)
  end
end
