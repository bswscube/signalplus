class Api::V1::ListenSignalsController < Api::V1::BaseController
  before_action :get_brand, only: [:index, :show]
  before_action :get_listen_signal, only: [:show]
  before_action :ensure_user_can_get_signal_info, only: [:index, :show]
  before_action :ensure_user_can_get_listen_signal, only: [:show]

  def update
    @listen_signal = ListenSignal.find(params[:id])
    signal_params = signal_params(params)
    @listen_signal.update_attributes!(signal_params)

    default_response = update_response(@listen_signal.default_response, params[:default_response])
    repeat_response = update_response(@listen_signal.repeat_response, params[:repeat_response])

    if @listen_signal 
      render json: @listen_signal, each_serializer: ListenSignalSerializer
    end
  end

  def create
    signal_params            = signal_params(params)
    signal_params[:brand]    = @brand
    signal_params[:identity] = @brand.twitter_identity
    default_response_msg     = params[:default_response]
    repeat_response_msg      = params[:repeat_response]

    ActiveRecord::Base.transaction do
      @listen_signal = ListenSignal.create!(signal_params)
      create_grouped_response(default_response_msg, repeat_response_msg)
    end

    if @listen_signal
      render json: @listen_signal, each_serializer: ListenSignalSerializer
  end

  def index
    render json: @brand.listen_signals, each_serializer: ListenSignalSerializer
  end

  def show
    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def templates
    render json: listen_signal_template_types
  end

  private

  def signal_params(params)
    params.permit(:name, :active, :signal_type, :expiration_date)
  end

  def get_listen_signal
    @listen_signal = ListenSignal.find(params[:id])
  end

  def ensure_user_can_get_signal_info
    if current_user.brand_id != @brand.id
      raise ApiErrors::StandardError.new(
        message: 'Sorry, you are not authorized to perfom this action',
        status: 401,
      )
    end
  end

  def ensure_user_can_get_listen_signal
    if !@brand.listen_signal_ids.include?(@listen_signal.id)
      raise ApiErrors::StandardError.new(
        message: 'Sorry, you are not authorized to perfom this action',
        status: 401,
      )
    end
  end

  def listen_signal_template_types
    {
      templates: {
        ListenSignal::Types::OFFER => 'Send a special offer every time a follower sends a custom hashtag',
        ListenSignal::Types::TODAY => 'Send a summary of your location or event each day a follower uses a custom hashtag',
        ListenSignal::Types::CONTEST => 'Run a contest for your followers for a specific date range',
        ListenSignal::Types::REMINDER => 'Send a reminder on a specific date to users when they use a custom hashtag',
      }
    }
  end

  def create_response_group
    ResponseGroup.create!(listen_signal: @listen_signal)
  end

  def create_response(message, type, response_group)
    Response.create_response(message, type, response_group)
  end

  def create_grouped_response(default_response_msg, repeat_response_msg)
    response_group = create_response_group
    create_response(default_response_msg, Response::Type::DEFAULT, response_group)
    create_response(repeat_response_msg, Response::Type::REPEAT, response_group)
  end

  def update_response(response, message)
    response.update!(message: message)
  end
end
