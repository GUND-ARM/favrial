class CreateSearchQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :search_queries do |t|
      t.string :query
      t.datetime :last_searched_at

      t.timestamps
    end
  end
end
