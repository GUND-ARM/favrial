class AddIndexToTweetsCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index :tweets, :created_at
  end
end
