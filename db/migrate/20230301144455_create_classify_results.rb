class CreateClassifyResults < ActiveRecord::Migration[7.0]
  def change
    create_table :classify_results do |t|
      t.string :classification
      t.boolean :result
      t.boolean :by_ml
      t.references :tweet
      t.references :user

      t.timestamps
    end
  end
end
