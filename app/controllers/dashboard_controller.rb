class DashboardController < ApplicationController
  respond_to :json

  before_action :check_current_user, only: [:index]

  def index
  end

  def contact
  end

  private

  def get_signal_type_text(signal_type)
    case signal_type
      when ListenSignal::Types::OFFERS
        'Send a special offer every time a follower sends a custom hashtag'
      when ListenSignal::Types::TODAY
        'Send a summary of your location or event each day a follower uses a custom hashtag'
      when ListenSignal::Types::CONTEST
        'Run a contest for your followers for a specific date range'
      when ListenSignal::Types::REMINDER
        'Send a reminder on a specific date to users when they use a custom hashtag'
      when ListenSignal::Types::SUPPORT
        'Notity users that you received their customer service request'
    end
  end

  def check_current_user
    if !current_user
      redirect_to new_user_session_path
      return
    end

    if !current_user.subscription? && !subscription_plans_path?
      redirect_to subscription_plans_path
      return
    end

    if !current_user.accepted_terms_of_use? && !subscription_plans_path? && !finish_setup_path?
      redirect_to finish_setup_path
      return
    end

    if current_user.accepted_terms_of_use? && finish_setup_path?
      redirect_to dashboard_index_path
      return
    end
  end

  # @return [Boolean]
  def subscription_plans_path?
    request.path[/^\/subscription_plans/]
  end

  # @return [Boolean]
  def finish_setup_path?
    request.path[/^\/finish_setup/]
  end
end
