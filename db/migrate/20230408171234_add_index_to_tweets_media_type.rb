class AddIndexToTweetsMediaType < ActiveRecord::Migration[7.0]
  def change
    add_index :tweets, :media_type
  end
end
