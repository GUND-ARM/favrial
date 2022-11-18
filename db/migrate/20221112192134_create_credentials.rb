class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.string :token
      t.integer :expires_at
      t.boolean :expires

      t.timestamps
    end
  end
end
