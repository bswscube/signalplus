# == Schema Information
#
# Table name: invoices
#
#  id                :integer          not null, primary key
#  stripe_invoice_id :string
#  brand_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  paid_at           :datetime
#  amount            :integer
#  data              :string
#

FactoryGirl.define do
  factory :invoice do
    brand
    stripe_invoice_id 'test_invoice_0001'
    amount 2000

    trait :paid do
      paid_at 1.day.ago
    end

    trait :unpaid do
      paid_at nil
    end
  end
end
