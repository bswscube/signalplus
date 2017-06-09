# == Schema Information
#
# Table name: responses
#
#  id                :integer          not null, primary key
#  message           :text
#  response_type     :string
#  response_group_id :integer
#  expiration_date   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  priority          :integer
#  deleted_at        :datetime
#

class Response < ApplicationRecord
  validates :message, :response_type, :response_group_id, presence: true

  acts_as_paranoid

  belongs_to :response_group
  has_many :twitter_responses

  module Type
    DEFAULT = 'default'
    FIRST   = 'first'
    TIMED   = 'timed'
    DATERANGE = 'daterange'
    FLOW    = 'flow'
    NOT_COUNTED = [
      REPEAT  = 'repeat',
      EXPIRED = 'expired',
    ]
  end

  DEFAULT_PRIORITY = {
    Type::DEFAULT => 0,
    Type::TIMED   => 0,
    Type::REPEAT  => 1000,
    Type::DATERANGE  => 2000,
  }

  def self.not_expired
    where(
      'coalesce("responses"."expiration_date", ?) > ?',
      Date.current + 1.day,
      Date.current
    )
  end

  def self.provider
    response_group.listen_signal.provider
  end

  def self.create_response(message, type, response_group)
    Response.create! do |r|
      r.message = message
      r.response_type = type
      r.response_group = response_group
      r.priority = DEFAULT_PRIORITY[type]
    end
  end

  def self.create_timed_response(message, exp_date, response_group)
    Response.create do |r|
      r.message = message
      r.response_type = Type::TIMED
      r.response_group_id = response_group.id
      r.expiration_date = exp_date
      r.priority = DEFAULT_PRIORITY[Type::TIMED]
    end
  end

  def self.create_daterange_response(message, start_date, end_date, response_group)
    Response.create do |r|
      r.message = message
      r.response_type = Type::DATERANGE
      r.response_group_id = response_group.id
      r.res_start_date = start_date
      r.res_end_date = end_date
      r.priority = DEFAULT_PRIORITY[Type::DATERANGE]
    end
  end



  def update_message(msg)
    update_attribute(:message, msg)
  end

  # @return [Boolean]
  def first?
    response_type == Type::FIRST
  end

  # @return [Boolean]
  def repeat?
    response_type == Type::REPEAT
  end

  # @return [Boolean]
  def default?
    response_type == Type::DEFAULT
  end

  # @return [Boolean]
  def timed?
    response_type == Type::TIMED
  end

  def daterange?
    response_type == Type::DATERANGE
  end

  # @return [Boolean]
  def expired?
    response_type == Type::EXPIRED
  end

  # @return [Boolean]
  def passed_expiration_date?
    return false unless expiration_date
    expiration_date < Date.current
  end

  # below are dummy methods to ensure that tests for sending tweets/dms with images
  # still pass
  # @return [Boolean]
  def has_image?
    false
  end

  # @return [Boolean]
  def paid?
    !Type::NOT_COUNTED.include?(response_type)
  end

  # @return [String]
  def image_name
    'puppy.gif'
  end

  # @return [Array]
  def for_sorting(last_response_priority)
    [
      passed_expiration_date? ? 1 : -1,
      priority > last_response_priority ? -1 : 1,
      priority,
      expiration_date ? -1 : 1,
      expiration_date,
    ]
  end
end
