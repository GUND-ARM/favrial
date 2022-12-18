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
end
