json.extract! tweet, :id, :t_id, :body, :url, :raw_json, :type, :classification, :classified, :created_at, :updated_at
json.url tweet_url(tweet, format: :json)
