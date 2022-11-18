class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :t_id
      t.text :body
      t.string :url
      t.text :raw_json
      t.string :type
      t.string :classification
      t.boolean :classified

      t.timestamps
    end
  end
end
