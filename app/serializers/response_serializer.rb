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

class ResponseSerializer < ActiveModel::Serializer
  attributes :id, :message, :response_type, :expiration_date, :res_start_date, :res_start_date, :priority
end
