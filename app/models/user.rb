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
