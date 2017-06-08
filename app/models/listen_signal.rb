# == Schema Information
#
# Table name: listen_signals
#
#  id              :integer          not null, primary key
#  brand_id        :integer
#  identity_id     :integer
#  name            :text
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  signal_type     :string
#  expiration_date :datetime
#  deleted_at      :datetime
#

class ListenSignal < ApplicationRecord
  validates :name, :brand_id, :identity_id, :signal_type, presence: true
  validates_uniqueness_of :name
  acts_as_paranoid

  belongs_to :brand
  belongs_to :identity
  has_one :response_group, dependent: :destroy
  has_many :responses, through: :response_group
  has_many :promotional_tweets, dependent: :destroy

  after_commit :toggle_twitter_streamer
  after_destroy :toggle_twitter_streamer

  module Types
    OFFERS      = :offers
    TODAY       = :today
    CONTEST     = :contest
    REMINDER    = :reminder
    CUSTOM      = :custom
    SUPPORT      = :support

    def self.values
      constants.map{ |t| const_get(t) }
    end
  end

  def self.active
    where(active: true)
  end

  def default_response
    responses.where(response_type: Response::Type::DEFAULT).first
  end

  def first_response
    responses.where(response_type: Response::Type::FIRST).first
  end

  def repeat_response
    responses.where(response_type: Response::Type::REPEAT).first
  end

  def timed_responses
    responses.where(response_type: Response::Type::TIMED)
  end

  def response(to)
    expired? ? response_group.expired_response : response_group.next_response(to)
  end

  def expired?
    expiration_date? && expiration_date <= Time.current
  end

  def last_promotional_tweet
    @last_promotional_tweet ||= promotional_tweets.last
  end

  private

  def toggle_twitter_streamer
    ToggleTwitterStreamWorker.perform_async(brand_id)
  end
end
