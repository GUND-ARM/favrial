require "test_helper"

class TweetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    use_omniauth
    # FIXME: これだと first_media_url が nil になってしまう
    @tweet = Tweet.find_or_create_with(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
  end

  test "should not get index without login" do
    get tweets_url
    assert_response :redirect
  end

  test "should get index" do
    login
    get tweets_url
    assert_response :success
  end

  test "should not get new without login" do
    get new_tweet_url
    assert_response :forbidden
  end

  test "should not get new" do
    login
    get new_tweet_url
    # FIXME: ツィートの手動追加を実装したらテストも修正する
    assert_response :forbidden
  end

  # FIXME: ツィートの手動追加を実装するときにテストも修正する
  test "should not create tweet" do
    #assert_difference("Tweet.count") do
    #  post tweets_url, params: { tweet: { body: @tweet.body, classification: @tweet.classification, classified: @tweet.classified, raw_json: @tweet.raw_json, t_id: @tweet.t_id, type: @tweet.type, url: @tweet.url } }
    #end

    #assert_redirected_to tweet_url(Tweet.last)

    post tweets_url, params: {
      tweet: {
        classification: @tweet.classification
      }
    }

    assert_response :forbidden
  end

  test "should not show tweet without login" do
    get tweet_url(@tweet)
    assert_response :forbidden
  end

  test "should show tweet" do
    login
    get tweet_url(@tweet)
    assert_response :success
  end

  test "should not get edit without login" do
    get edit_tweet_url(@tweet)
    assert_response :forbidden
  end

  test "should get edit with login" do
    login
    get edit_tweet_url(@tweet)
    assert_response :success
  end

  test "should not update tweet without login" do
    patch tweet_url(@tweet), params: {
      tweet: {
        a_classification: @tweet.classification
      }
    }
    assert_response :forbidden
  end

  test "should update tweet with login" do
    login
    patch tweet_url(@tweet), params: {
      tweet: {
        a_classification: @tweet.classification
      }
    }
    assert_redirected_to tweet_url(@tweet)
  end

  # FIXME: ツィートの削除を実装したときにテストも修正する
  test "should not destroy tweet" do
    #assert_difference("Tweet.count", -1) do
    #  delete tweet_url(@tweet)
    #end
    #assert_redirected_to tweets_url

    delete tweet_url(@tweet)
    assert_response :forbidden
  end
end
