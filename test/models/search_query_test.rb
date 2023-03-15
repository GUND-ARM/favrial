require "test_helper"

class SearchQueryTest < ActiveSupport::TestCase
  test "findできる" do
    query = search_queries(:one)
    assert_equal "#スレミオ", query.query
    assert_equal DateTime.iso8601('2023-03-15T15:53:57'), query.last_searched_at
  end
end
