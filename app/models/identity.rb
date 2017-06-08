# == Schema Information
#
# Table name: identities
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  brand_id          :integer
#  provider          :string
#  uid               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  encrypted_token   :string
#  encrypted_secret  :string
#  user_name         :string
#  profile_image_url :string
#  deleted_at        :datetime
#

class Identity < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :brand
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid,      scope: :provider
  validates_uniqueness_of :brand_id, scope: :provider

  module Provider
    ALL = [
      TWITTER = 'twitter',
      FACEBOOK = 'facebook'
    ]
  end

  def self.find_for_oauth(auth)
    find_or_create_by!(uid: auth.uid, provider: auth.provider) do |i|
      i.encrypted_token  = encrypt(auth.extra.access_token.token)
      i.encrypted_secret = encrypt(auth.extra.access_token.secret)
    end
  end

  def self.encrypt(key)
    cipher = Gibberish::AES.new(ENV['IDENTITY_SALT'])
    cipher.encrypt(key).to_s
  end

  def self.decrypt(encrypted_key)
    cipher = Gibberish::AES.new(ENV['IDENTITY_SALT'])
    cipher.decrypt(encrypted_key).to_s
  end

  def decrypted_token
    self.class.decrypt(encrypted_token)
  end

  def decrypted_secret
    self.class.decrypt(encrypted_secret)
  end
end
