class AddIndexToUsersProtected < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :protected
  end
end
