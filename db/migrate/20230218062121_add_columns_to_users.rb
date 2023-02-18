class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :protected, :boolean
    add_column :users, :location, :string
    add_column :users, :url, :string
    add_column :users, :description, :string
    add_column :users, :profile_image_url, :string
  end
end
