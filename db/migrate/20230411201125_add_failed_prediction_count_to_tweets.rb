class AddFailedPredictionCountToTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :failed_prediction_count, :integer
  end
end
