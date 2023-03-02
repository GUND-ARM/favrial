require "test_helper"

class ClassifyResultTest < ActiveSupport::TestCase
  # AIが分類結果を追加できる
  test "add classify result by AI" do
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      by_ml: true,
      tweet: tweet
    )
    assert classify_result.save
  end

  # 人間が分類結果を追加できる
  test "add classify result by human" do
    user = users(:one)
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save
  end

  # classificationは定義された値のみを許可する
  test "classification should be defined value" do
    user = users(:one)
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: "hoge",
      result: true,
      tweet: tweet,
      user: user
    )
    assert_not classify_result.save
  end

  # resultはtrueかfalseのみを許可する
  test "result should be true or false" do
    user = users(:one)
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: nil, # nilだとsaveに失敗するはず
      tweet: tweet,
      user: user
    )
    assert_not classify_result.save
  end

  # by_mlはtrueかfalseのみを許可する
  test "by_ml should be true or false" do
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      by_ml: nil, # nilだとsaveに失敗するはず
      tweet: tweet
    )
    assert_not classify_result.save
  end

  # tweetがないと保存できない
  test "tweet should be present" do
    user = users(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      user: user
    )
    assert_not classify_result.save
  end

  # 1ユーザーが1ツィートにつき1つの分類結果しか追加できない
  test "user can add only one classify result for one tweet if same classification" do
    user = users(:one)
    tweet = tweets(:one)

    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save

    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert_not classify_result.save
  end

  # AIは1ツィートにつき1つの分類結果しか追加できない
  test "AI can add only one classify result for one tweet if same classification" do
    tweet = tweets(:one)

    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      by_ml: true,
      tweet: tweet
    )
    assert classify_result.save

    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      by_ml: true,
      tweet: tweet
    )
    assert_not classify_result.save
  end

  # 1ツィートにつき, 分類が異なれば複数の分類結果を追加できる
  test "user can add multiple classify result for one tweet if different classifications" do
    user = users(:one)
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save

    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::GWITCH,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save
  end

  # 1ツィートにつき, 分類が同じでもAIが追加した分類結果と人間が追加した分類結果は別々に保存できる
  test "user can add multiple classify result for one tweet if same classification but different by_ml" do
    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      by_ml: true,
      tweet: tweet
    )
    assert classify_result.save

    user = users(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save
  end

  # 異なるツィートであれば, 同じユーザーが同じ分類を複数回追加できる
  test "user can add multiple classify result for different tweets if same classification" do
    user = users(:one)

    tweet = tweets(:one)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save

    tweet = tweets(:two)
    classify_result = ClassifyResult.new(
      classification: ClassifyResult::Classification::SULEMIO,
      result: true,
      tweet: tweet,
      user: user
    )
    assert classify_result.save
  end
end
