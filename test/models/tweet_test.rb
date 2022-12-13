require "test_helper"

class TweetTest < ActiveSupport::TestCase
  test "APIレスポンスの1ツィートのHashとメディアタイプからレコードを1つ作成できる" do
    tweet = Tweet.find_or_create_from_tweet_hash_with_media_type(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    assert tweet.persisted?
    assert_equal tweet.t_id, "1600535525244698626"
    assert_equal tweet.media_type, Tweet::MediaType::PHOTO
  end

  test "t_id が既に存在している場合は作成しない" do
    Tweet.find_or_create_from_tweet_hash_with_media_type(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    Tweet.find_or_create_from_tweet_hash_with_media_type(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    assert_equal 1, Tweet.count
  end

  test "APIレスポンスのJSON全体のHashから複数のレコードを作成できる" do
    Tweet.create_many_from_api_response(timeline_api_response)
    tweet = Tweet.find_by(t_id: "1600403285202305024")
    assert_equal tweet.media_type, Tweet::MediaType::PHOTO
  end
end
