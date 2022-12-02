class AddRefreshTokenToCredentials < ActiveRecord::Migration[7.0]
  def change
    add_column :credentials, :refresh_token, :string
  end
end
