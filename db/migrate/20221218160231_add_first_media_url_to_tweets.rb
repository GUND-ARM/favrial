class AddFirstMediaUrlToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :first_media_url, :string
  end
end
