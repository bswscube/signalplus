class Api::V1::ListenSignalsController < Api::V1::BaseController
  before_action :get_brand, only: [:index, :show, :create, :update, :destroy]
  before_action :get_listen_signal, only: [:show, :destroy, :update]
  before_action :ensure_user_can_get_signal_info, only: [:index, :show, :destroy]
  before_action :ensure_user_can_get_listen_signal, only: [:show, :destroy]
  before_action :has_valid_subscription?, only: [:update, :create]

  def index
    render json: @brand.listen_signals, each_serializer: ListenSignalSerializer
  end

  def show
    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def templates
    render json: listen_signal_template_types
  end

  def update
    request_method = request.env['REQUEST_METHOD']
    if request_method == 'PUT'
      put_update
    elsif request_method == 'PATCH'
      patch_update
    end

    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def create
    signal_params            = create_signal_params
    response_params          = create_response_params
    signal_params[:brand]    = @brand
    signal_params[:identity] = @brand.twitter_identity

    listen_signal_handler = ListenSignalHandler.new(nil, signal_params, response_params)
    @listen_signal = listen_signal_handler.create

    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def destroy
    @listen_signal.destroy

    head :no_content
  end

  private

  def create_signal_params
    params.permit(:name, :active, :signal_type)
  end

  def create_response_params
    params.permit(:default_response, :repeat_response, { responses: [:id, :message, :expiration_date, :res_start_date] })
  end

  def update_signal_params
    params.permit(:signal_type, :expiration_date, :res_start_date)
  end

  def patch_signal_params
    params.permit(:active)
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
        ListenSignal::Types::OFFERS => 'Send a special offer every time a follower sends a custom hashtag',
        ListenSignal::Types::TODAY => 'Send a summary of your location or event each day a follower uses a custom hashtag',
        ListenSignal::Types::CONTEST => 'Run a contest for your followers for a specific date range',
        ListenSignal::Types::REMINDER => 'Send a reminder on a specific date to users when they use a custom hashtag',
        ListenSignal::Types::CUSTOM => 'Create your own custom response whenever a follower sends a custom hashtag',    ListenSignal::Types::SUPPORT => 'Notity users that you received their customer service request'    }
    }
  end

  def patch_update
    @listen_signal.update!(patch_signal_params)
  end

  def put_update
    signal_params = update_signal_params
    response_params = create_response_params

    listen_signal_handler = ListenSignalHandler.new(@listen_signal, signal_params, response_params)
    listen_signal_handler.update
  end
end
