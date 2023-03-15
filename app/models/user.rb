# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  username          :string
#  name              :string
#  uid               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  protected         :boolean
#  location          :string
#  url               :string
#  description       :string
#  profile_image_url :string
#
class User < ApplicationRecord
  has_one :credential, dependent: :destroy
  has_many :tweets
  has_many :classify_results

  validates :uid, presence: true, uniqueness: true

  scope :with_credentials, -> { joins(:credential) }

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

  def self.find_or_create_by_uid(uid)
    User.find_or_create_by(uid: uid)
  end

  # 新規追加されたユーザの情報をTwitter APIから取得して更新する
  # 100件以上のユーザ情報を更新する場合は、100件ごとに分割して更新する
  def self.bulk_update_new_users(access_user:)
    User.where(username: nil).limit(1000).each_slice(100) do |users|
      ids = users.map(&:id)
      update_from_twitter_api(access_user: access_user, ids: ids)
    end
  end

  # 全てのユーザの情報をTwitter APIから取得して更新する
  #
  # @param access_user: User Twitter APIにアクセスするためのユーザ（認証済みのユーザ）
  # @return: [User] 更新されたユーザの配列
  def self.bulk_update_users(access_user:)
    User.all.each_slice(100) do |users|
      ids = users.map(&:id)
      update_from_twitter_api(access_user: access_user, ids: ids)
    end
  end

  # 6時間以上更新されていないユーザの情報をTwitter APIから取得して更新する
  # FIXME: updated_at だと、変更が無い場合は更新されないので、別のカラムを用意する
  def self.bulk_update_outdated_users(access_user:)
    User.where("updated_at < ?", 6.hours.ago).limit(1000).each_slice(100) do |users|
      ids = users.map(&:id)
      update_from_twitter_api(access_user: access_user, ids: ids)
    end
  end

  # Twitter APIからユーザ情報を更新する
  def self.update_from_twitter_api(access_user:, ids:)
    raise ArgumentError, "ids must be an array" unless ids.is_a?(Array)
    raise ArgumentError, "ids must not be empty" if ids.empty?
    raise ArgumentError, "ids count must be up to 100" if ids.count > 100

    uids = User.where(id: ids).pluck(:uid)
    users_hash = TwitterAPI::Client.users(access_user.credential.token, uids)
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
    res = TwitterAPI::Client.users_timelines_reverse_chronological(
      credential.token,
      uid,
      pagination_token
    )
    tweets_response = TwitterAPI::TweetsResponse.new(res)
    # FIXME: Copilotくんが save_tweets_from_api_response のほうがいいよって言ってた
    Tweet.create_many_from_api_response(tweets_response)
    return tweets_response
  end
end
