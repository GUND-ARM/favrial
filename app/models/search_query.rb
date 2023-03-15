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
class SearchQuery < ApplicationRecord
end
