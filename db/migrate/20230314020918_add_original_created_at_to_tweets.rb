class AddOriginalCreatedAtToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :original_created_at, :datetime
    add_index :tweets, :original_created_at
  end
end
