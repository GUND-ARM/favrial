class AddIndexToTweetsTId < ActiveRecord::Migration[7.0]
  def change
    add_index :tweets, :t_id, unique: true
  end
end
