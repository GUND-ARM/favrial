# == Schema Information
#
# Table name: tweets
#
#  id              :bigint           not null, primary key
#  t_id            :string
#  body            :text
#  url             :string
#  raw_json        :text
#  media_type      :string
#  classification  :string
#  classified      :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  first_media_url :string
#  user_id         :bigint
#
require "test_helper"

class TweetTest < ActiveSupport::TestCase
  test "APIレスポンスの1ツィートのHashとメディアタイプからレコードを1つ作成できる" do
    tweet = Tweet.find_or_create_with(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    assert tweet.persisted?
    assert_equal tweet.t_id, "1600535525244698626"
    assert_equal tweet.media_type, Tweet::MediaType::PHOTO
  end

  test "t_id が既に存在している場合は作成しない" do
    Tweet.destroy_all
    Tweet.find_or_create_with(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    Tweet.find_or_create_with(
      tweet_hash: tweet_hash_with_media,
      media_type: Tweet::MediaType::PHOTO
    )
    assert_equal 1, Tweet.count
  end

  test "APIレスポンスのJSON全体のHashから複数のレコードを作成できる" do
    response = TwitterAPI::TweetsResponse.new(reverse_chronological_response)
    Tweet.create_many_from_api_response(response)
    tweet = Tweet.find_by(t_id: "1604509826498691073")
    assert_equal tweet.first_media_url, "https://pbs.twimg.com/media/FkRdIYgUYAE5q9N.jpg"
    assert_equal tweet.media_type, Tweet::MediaType::PHOTO
  end

  test "Userを関連付けて保存できる" do
    user = users(:one)
    tweet = Tweet.new(
      t_id: "1600535525244698626",
      body: "test",
      raw_json: "{}",
      media_type: Tweet::MediaType::PHOTO,
      classification: Tweet::Classification::SULEMIO
    )
    tweet.user = user
    tweet.save
    assert tweet.persisted?
    assert_equal tweet.user, user
  end

  test "Userを関連付けなくても保存できる" do
    tweet = Tweet.new(
      t_id: "1600535525244698626",
      body: "test",
      raw_json: "{}",
      media_type: Tweet::MediaType::PHOTO,
      classification: Tweet::Classification::SULEMIO
    )
    tweet.save
    assert tweet.persisted?
    assert_nil tweet.user
  end

  test "関連付けられたUserが実際に存在するレコードのみ取得する" do
    user_1 = users(:one)
    tweet_1 = Tweet.new(
      t_id: "1600535525244698626",
      body: "test 1",
      raw_json: "{}",
      media_type: Tweet::MediaType::PHOTO,
      classification: Tweet::Classification::SULEMIO
    )
    tweet_1.user = user_1
    tweet_1.save
    user_2 = users(:two)
    tweet_2 = Tweet.new(
      t_id: "1600535525244698627",
      body: "test 2",
      raw_json: "{}",
      media_type: Tweet::MediaType::PHOTO,
      classification: Tweet::Classification::SULEMIO
    )
    tweet_2.user = user_2
    tweet_2.save
    user_2.destroy
    assert_equal Tweet.joins(:user).count, 1
  end

  test "AIがスレミオだと仮分類したツィートのみ取得する" do
    # unprotectedなユーザのツィートかどうか判別するためにuserを関連付ける
    Tweet.all.each do |tweet|
      tweet.user = users(:one)
      tweet.save!
    end

    # @type [Tweet]
    tweet_1 = tweets(:one)
    tweet_1.classify_sulemio_by_ml(result: true)

    # @type [Tweet]
    tweet_2 = tweets(:two)
    tweet_2.classify_sulemio_by_ml(result: true)

    # @type [Tweet]
    tweet_3 = tweets(:three)
    tweet_3.classify_sulemio_by_ml(result: false)

    # @type [Tweet]
    tweet_4 = tweets(:four)
    user = users(:one)
    tweet_4.classify_sulemio_by_user(user: user, result: true)

    assert_equal 2, Tweet.pre_classified_with_sulemio_photo.count
  end

  test "ユーザがスレミオだと判断したツィートのみ取得する" do
    # unprotectedなユーザのツィートかどうか判別するためにuserを関連付ける
    Tweet.all.each do |tweet|
      tweet.user = users(:one)
      tweet.save!
    end

    # @type [Tweet]
    tweet_1 = tweets(:one)
    tweet_1.classify_sulemio_by_ml(result: true)

    # @type [Tweet]
    tweet_2 = tweets(:two)
    tweet_2.classify_sulemio_by_ml(result: true)

    # @type [Tweet]
    tweet_3 = tweets(:three)
    tweet_3.classify_sulemio_by_user(user: users(:one), result: true)

    # @type [Tweet]
    tweet_4 = tweets(:four)
    tweet_4.classify_sulemio_by_user(user: users(:one), result: false)

    assert_equal 1, Tweet.classified_with_sulemio_photo.count
  end

  test "ユーザがスレミオだと判断したツィートは sulemio? がtrueを返す" do
    # unprotectedなユーザのツィートかどうか判別するためにuserを関連付ける
    Tweet.all.each do |tweet|
      tweet.user = users(:one)
      tweet.save!
    end

    # @type [Tweet]
    tweet_1 = tweets(:one)
    tweet_1.classify_sulemio_by_ml(result: true)
    assert_not tweet_1.sulemio?

    # @type [Tweet]
    tweet_2 = tweets(:two)
    tweet_2.classify_sulemio_by_user(user: users(:one), result: true)
    assert tweet_2.sulemio?
  end
end
