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

    User.find_or_create_by(uid: uid) do |user|
      user.name = name
      user.username = username
      user.credential = Credential.from_credentials_hash(credentials)
    end
  end
end
