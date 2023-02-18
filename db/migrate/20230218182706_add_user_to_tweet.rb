class AddUserToTweet < ActiveRecord::Migration[7.0]
  def change
    add_reference :tweets, :user
  end
end
