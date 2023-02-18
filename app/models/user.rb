# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  username   :string
#  name       :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_one :credential, dependent: :destroy

  validates :uid, presence: true
  validates :name, presence: true
  validates :username, presence: true

  def self.find_or_create_from_auth_hash(auth_hash)
    h = ActiveSupport::HashWithIndifferentAccess.new(auth_hash)
    uid = h[:uid]
    name = h[:info][:name]
    username = h[:info][:nickname]
    credentials = h[:credentials]
    User.find_and_save_with_oauth_params(uid, name, username, credentials)
  end

  def self.find_and_save_with_oauth_params(uid, name, username, credentials)
    u = User.find_or_initialize_by(uid: uid)
    u.name = name
    u.username = username
    u.credential = Credential.from_credentials_hash(credentials)
    u.save
    return u
  end

  def self.find_or_create_many_from_api_response(users_hash)
    users_hash.map do |user_hash|
      User.find_or_create_from_api_response(user_hash)
    end
  end

  def self.find_or_create_from_api_response(user_hash)
    u = User.find_or_initialize_by(uid: user_hash[:id])
    u.name = user_hash[:name]
    u.username = user_hash[:username]
    u.protected = user_hash[:protected]
    u.location = user_hash[:location]
    u.url = user_hash[:url]
    u.description = user_hash[:description]
    u.profile_image_url = user_hash[:profile_image_url]
    u.save
    return u
  end

  # Twitter APIからユーザ情報を更新する
  def self.update_from_twitter_api(access_user:, ids:)
    twitter_ids = User.where(id: ids).pluck(:uid)
    users_hash = TwitterAPI::Client.get_users(access_user, twitter_ids)
    User.find_or_create_many_from_api_response(users_hash[:data])
  end

  # ホームタイムラインを指定回数さかのぼって取得する
  def fetch_reverse_chronological_timelines(fetch_count = 1)
    pagination_token = nil
    fetch_count.times do
      tweets_response = fetch_reverse_chronological_timeline(pagination_token)
      pagination_token = tweets_response.next_token
      break unless pagination_token
    end
  end

  # ホームタイムラインをAPIアクセス1回分取得する
  def fetch_reverse_chronological_timeline(pagination_token)
    tweets_response = TwitterAPI::Client.fetch_timelines_reverse_chronological(
      self,
      pagination_token
    )
    # FIXME: Copilotくんが save_tweets_from_api_response のほうがいいよって言ってた
    Tweet.create_many_from_api_response(tweets_response)
    return tweets_response
  end
end
