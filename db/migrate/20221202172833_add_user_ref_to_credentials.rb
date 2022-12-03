class AddUserRefToCredentials < ActiveRecord::Migration[7.0]
  def change
    add_reference :credentials, :user, foreign_key: true
  end
end
