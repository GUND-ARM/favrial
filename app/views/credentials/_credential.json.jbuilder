json.extract! credential, :id, :token, :expires_at, :expires, :created_at, :updated_at
json.url credential_url(credential, format: :json)
