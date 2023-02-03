json.extract! user, :id, :screen_name, :name, :t_id, :created_at, :updated_at
json.url user_url(user, format: :json)
