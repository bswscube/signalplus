# == Schema Information
#
# Table name: response_groups
#
#  id               :integer          not null, primary key
#  listen_signal_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class ResponseGroup < ApplicationRecord
  acts_as_paranoid

  belongs_to :listen_signal
  has_many :responses, dependent: :destroy
  has_many :non_expired_responses, -> { not_expired }, class_name: 'Response'
  has_many :twitter_responses

  # @param [String] Who the response should be sent to
  # @return [Response]
  def next_response(to)
    last_response_priority = get_last_response_priority(to) || -1
    find_next_response(last_response_priority) || default_response
  end

  # @return [ActiveRecord::Relation]
  def ordered_responses_for_reply(to)
    non_expired_responses
      .joins(:twitter_responses)
      .where(twitter_responses: { to: to, date: Date.current })
      .where.not(twitter_responses: { reply_tweet_id: nil })
      .where.not(response_type: Response::Type::EXPIRED)
      .order(expiration_date: :desc)
      .order(priority: :asc)
  end

  # @return [Fixnum]
  def get_last_response_priority(to)
    ordered_responses_for_reply(to).limit(1).pluck(:priority).first
  end

  # @return [Response]
  def default_response
    responses.find(&:default?)
  end

  # @return [Response]
  def repeat_response
    responses.find(&:repeat?)
  end

  # @return [Response]
  def expired_response
    responses.find(&:expired?)
  end

  # @return [Array<Response>]
  def timed_responses
    responses.find_all(&:timed?)
  end

  def daterange_response
    responses.find_all(&:daterange?)
  end

  # @return [Response, NilClass]
  def find_next_response(last_response_priority)
    response = sorted_responses_for_reply(last_response_priority).first
    response.priority > last_response_priority ? response : nil
  end

  # Sort ascending so that we can grab the first one
  # @return [Array]
  def sorted_responses_for_reply(last_response_priority)
    non_expired_responses.sort_by do |response|
      response.for_sorting(last_response_priority)
    end
  end
end
