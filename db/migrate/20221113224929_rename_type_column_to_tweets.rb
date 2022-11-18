class RenameTypeColumnToTweets < ActiveRecord::Migration[7.0]
  def change
    rename_column :tweets, :type, :media_type
  end
end
