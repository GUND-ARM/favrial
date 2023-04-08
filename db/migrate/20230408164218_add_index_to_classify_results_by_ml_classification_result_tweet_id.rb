class AddIndexToClassifyResultsByMlClassificationResultTweetId < ActiveRecord::Migration[7.0]
  def change
    add_index :classify_results, [:by_ml, :classification, :result, :tweet_id],
              name: 'index_classify_results_on_by_ml_classification_result_tweet_id'
  end
end
