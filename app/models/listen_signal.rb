# == Schema Information
#
# Table name: listen_signals
#
#  id              :integer          not null, primary key
#  brand_id        :integer
#  identity_id     :integer
#  name            :text
#  expiration_date :datetime
#  active          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ListenSignal < ActiveRecord::Base
  belongs_to :brand
  belongs_to :identity
  has_one :response_group
  has_many :responses, through: :response_group

  def response(to)
    response_group.next_response(to)
  end

  def self.active
    where(active: true)
      .where('expiration_date > ?', Time.current)
  end

end
