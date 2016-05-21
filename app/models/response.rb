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
#

class Response < ActiveRecord::Base
  belongs_to :response_group
  has_many :twitter_responses

  def self.provider
    response_group.listen_signal.provider
  end

  def has_image?
    false
  end
end
