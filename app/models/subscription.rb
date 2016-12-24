# == Schema Information
#
# Table name: subscriptions
#
#  id                     :integer          not null, primary key
#  brand_id               :integer
#  subscription_plan_id   :integer
#  provider               :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  canceled_at            :datetime
#  trial_end              :datetime         not null
#  trial                  :boolean          default(TRUE)
#  deleted_at             :datetime
#  lock_version           :integer          default(0)
#  will_be_deactivated_at :datetime
#

class Subscription < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :brand
  belongs_to :subscription_plan

  has_paper_trail only: [
    :subscription_plan_id,
    :canceled_at,
    :will_be_deactivated_at,
  ], on: [:update]

  NUMBER_OF_DAYS_OF_TRIAL = ENV['NUMBER_OF_DAYS_OF_TRIAL'].to_i
  MAX_NUMBER_OF_MESSAGES_FOR_TRIAL = ENV['MAX_NUMBER_OF_MESSAGES_FOR_TRIAL'].to_i

  class << self
    # Subscribes a brand to to a subscription plan. Handles error outside of this method
    #
    # @param brand             [Brand] A brand object
    # @param subscription_plan [SubscriptionPlan] A subscription plan object
    # @param email             [String] email of the customer
    # @param stripe_token      [String] The Stripe token response necessary to create the Stripe
    #                                   Customer object and their Stripe subscription
    def subscribe!(brand, subscription_plan, email, stripe_token)
      trial_end = NUMBER_OF_DAYS_OF_TRIAL.days.from_now
      customer = create_customer!(subscription_plan, email, stripe_token, trial_end.to_i)

      if customer
        stripe_subscription_id = customer.subscriptions.first.id
        create_payment_handler!(brand, customer)
        create_subscription!(brand, subscription_plan, stripe_subscription_id, trial_end)
      end
    end

    # Resubscribes a brand to a subscription if their previous subscription was deactivated
    #
    # @param brand             [Brand] A brand object
    # @param subscription_plan [SubscriptionPlan] A subscription plan object
    def resubscribe!(brand, subscription_plan)
      stripe_subscription = create_stripe_subscription!(
        brand.payment_handler.token,
        subscription_plan.provider_id
      )

      create_subscription!(brand, subscription_plan, stripe_subscription.id)
    end

    private

    # Creates the Stripe customer and subscribes them to a trial subscription
    #
    # @param brand             [Brand]
    # @param subscription_plan [SubscriptionPlan]
    # @param email             [String]
    # @param stripe_token      [String]
    # @param trial_end         [Fixnum] Unix timestamp for when the trial is supposed to end
    # @return                  [Stripe::Customer]
    def create_customer!(subscription_plan, email, stripe_token, trial_end)
      Stripe::Customer.create(
        source:    stripe_token,
        plan:      subscription_plan.provider_id,
        email:     email,
        trial_end: trial_end,
      )
    end

    # Used when resubscribing a user to a subscription
    #
    # @param customer [String]
    # @param plan     [String]
    # @return [Stripe::Subscription]
    def create_stripe_subscription!(customer, plan)
      Stripe::Subscription.create(
        customer: customer,
        plan: plan,
      )
    end

    def create_payment_handler!(brand, customer)
      PaymentHandler.create!(
        brand_id: brand.id,
        provider: 'Stripe',
        token:    customer.id,
      )
    end

    # Creates the Subscription within our DB
    #
    # @param brand                  [Brand]
    # @param subscription_plan      [SubscriptionPlan]
    # @param stripe_subscription_id [String]
    # @param trial_end              [ActiveSupport::TimeWithZone]
    # @return                       [Subscription]
    def create_subscription!(brand, subscription_plan, stripe_subscription_id, trial_end = nil)
      create!(
        brand_id:             brand.id,
        subscription_plan_id: subscription_plan.id,
        provider:             'Stripe',
        token:                stripe_subscription_id,
        trial_end:            trial_end,
        trial:                !!trial_end,
      )
    end
  end

  # Updates the subscription's subscription plan
  #
  # @param subscription_plan [SubscriptionPlan] A subscription plan object
  # @return [Subscription]
  def update_plan!(subscription_plan)
    if deactivated?
      resubscribe_and_destroy!(subscription_plan)
    else
      update_stripe_subscription!(subscription_plan)
      update!(
        subscription_plan_id: subscription_plan.id,
        canceled_at: nil,
        will_be_deactivated_at: nil,
      )
      self
    end
  rescue Stripe::InvalidRequestError
    resubscribe_and_destroy!(subscription_plan)
  end

  # Cancels the subscription plan
  def cancel_plan!
    cancel_stripe_subscription!
    update!(
      canceled_at: Time.at(stripe_subscription.canceled_at),
      will_be_deactivated_at: Time.at(stripe_subscription.current_period_end),
    )
  end

  # Forcefully ends the trial subscription
  def end_trial!
    end_stripe_trial_subscription!
    update!(trial: false)
  end

  # @return [Stripe::Subscription]
  def stripe_subscription
    @stripe_subscription ||= Stripe::Subscription.retrieve(token)
  end

  # @return [Boolean]
  def canceled?
    !canceled_at.nil?
  end

  # @return [String]
  def name
    subscription_plan.try(:name)
  end

  # @return [Fixnum]
  def number_of_messages
    subscription_plan.try(:number_of_messages)
  end

  # TODO - use Stripe webhooks to keep this up-to-date
  # @return [Boolean]
  def past_due?
    false
  end

  # TODO - use Stripe webhooks to keep this up-to-date
  # @return [Boolean]
  def unpaid?
    false
  end

  # @return [Boolean]
  def deactivated?
    will_be_deactivated_at? && will_be_deactivated_at <= Time.current
  end

  # @return [Boolean]
  def valid_and_paid_for?
    !canceled? && !past_due? && !unpaid?
  end

  def monthly_twitter_responses
    @monthly_twitter_responses ||= brand.monthly_twitter_responses
  end

  def monthly_response_count
    monthly_twitter_responses.count
  end

  private

  # Used to stub out in tests for mocking of the Stripe API response
  def update_stripe_subscription!(subscription_plan)
    stripe_subscription.plan = subscription_plan.provider_id
    # Don't prorate
    # TODO: test with downgrading
    stripe_subscription.prorate = false
    stripe_subscription.save
  end

  def end_stripe_trial_subscription!
    stripe_subscription.trial_end = "now"
    stripe_subscription.save
  end

  def cancel_stripe_subscription!
    stripe_subscription.delete(at_period_end: true)
  end

  def resubscribe_and_destroy!(subscription_plan)
    Subscription.transaction do
      destroy!
      Subscription.resubscribe!(brand, subscription_plan)
    end
  end
end
