# == Schema Information
#
# Table name: search_queries
#
#  id               :bigint           not null, primary key
#  query            :string
#  last_searched_at :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class SearchQueryTest < ActiveSupport::TestCase
  test "findできる" do
    query = search_queries(:one)
    assert_equal "#スレミオ", query.query
    assert_equal DateTime.iso8601('2023-03-15T15:53:57'), query.last_searched_at
  end
end
