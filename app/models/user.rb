# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  brand_id               :integer
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  tokens                 :json
#  email_subscription     :boolean          default(FALSE)
#  deleted_at             :datetime
#

class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  acts_as_paranoid
  has_paper_trail only: [:email], on: [:update]

  after_save :handle_subscription, if: :email_verified?
  before_save :log_changing_of_tokens

  # Include default devise modules.
  devise :omniauthable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/


  belongs_to :brand

  class << self

    def find_for_oauth(auth, signed_in_resource = nil)
      brand = nil
      # Get the identity and user if they exist
      identity = Identity.find_for_oauth(auth)
      # If a signed_in_resource is provided it always overrides the existing user
      # to prevent the identity being locked with accidentally created accounts.
      # Note that this may leave zombie accounts (with no associated identity) which
      # can be cleaned up at a later date.
      user = signed_in_resource ? signed_in_resource : identity.user

      # Create the user if needed
      if user.nil?
        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified

        # Create the user if it's a new registration
        if user.nil?
          brand = Brand.create!(name: auth.info.name)

          user = User.new(
            name:         auth.extra.raw_info.name,
            email:        email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
            password:     Devise.friendly_token[0, 20],
            brand:        brand,
            confirmed_at: Time.current, # Needed for devise_token_auth gem
            email_subscription: false
          )
          user.save!
        end
      end

      # Associate the identity with the user and the brand if needed
      if identity.user != user
        identity.user              = user
        identity.brand             = brand
        identity.user_name         = auth.extra.raw_info.screen_name
        identity.profile_image_url = auth.extra.raw_info.profile_image_url
        identity.save!
      end

      user
    end
  end

  def subscription?
    !!brand.try(:subscription?)
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  def email_previously_verified?
    self.email_was && self.email_was !~ TEMP_EMAIL_REGEX
  end

  def handle_subscription
    if changes.key?(:email) && email_subscription_was
      unsubscribe_previous_email_from_newsletter if email_previously_verified?
      subscribe_to_newsletter if email_subscription
    elsif email_subscription && !email_subscription_was
      subscribe_to_newsletter
    elsif !email_subscription && changes.key?(:email_subscription)
      unsubscribe_from_newsletter
    end
  end

  def encrypted_email
    Digest::MD5.hexdigest(email.downcase)
  end

  def previous_encrypted_email
    Digest::MD5.hexdigest(email_was.downcase)
  end

  def encrypted_email
    Digest::MD5.hexdigest(email.downcase)
  end

  def previous_encrypted_email
    Digest::MD5.hexdigest(email_was.downcase)
  end

  def subscribe_to_newsletter
    EmailSubscriptionWorker.perform_async(id)
  end

  def unsubscribe_from_newsletter
    EmailRemoveSubscriptionWorker.perform_async(encrypted_email)
  end

  def unsubscribe_previous_email_from_newsletter
    EmailRemoveSubscriptionWorker.perform_async(previous_encrypted_email)
  end

  # @return [Boolean]
  def accepted_terms_of_use?
    brand ? brand.accepted_terms_of_use? : false
  end

  def log_changing_of_tokens
    if Rails.env.development? && tokens_changed?
      puts "Changing tokens!!!"
      puts "Changing from:"
      puts tokens_was
      puts "to:"
      puts tokens
    end
  end
end
