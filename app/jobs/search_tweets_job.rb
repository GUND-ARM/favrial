class SearchTweetsJob < ApplicationJob
  queue_as :default

  def perform(page_count = 10)
    # FIXME: 新規キーワードと既存キーワードを一緒に検索できるようにする
    #          - 新規キーワードが10件以上ある場合は、新規キーワードを優先して検索する
    #          - 新規キーワードが10件未満の場合は、合計10件になるまで既存キーワードを検索する
    #        現状は, 最悪の場合（1ユーザが全てのキーワードの検索をおこなう）を想定して合計160件になるようにしている

    # 最後に検索した時刻が古いキーワードから8件検索するようにする
    SearchQuery.where.not(last_searched_at: nil).order(last_searched_at: :asc).limit(8).each do |search_query|
      begin
        search(search_query: search_query, page_count: page_count)
      rescue => e
        Rails.logger.error(e)
      end
    end

    # 新規キーワードを8件検索する
    SearchQuery.where(last_searched_at: nil).limit(8).each do |search_query|
      begin
        search(search_query: search_query, page_count: page_count)
      rescue => e
        Rails.logger.error(e)
      end
    end

    return true
  end

  private

  def search(search_query:, page_count:)
    access_user = User.with_credentials.sample
    query = search_query.query
    Rails.logger.info("Search for: #{query} by #{access_user.username}")
    Tweet.save_searched_tweets(access_user:, query: query, count: page_count)
    search_query.last_searched_at = DateTime.now
    search_query.save!
  end
end
