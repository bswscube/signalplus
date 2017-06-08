class Api::V1::PromotionalTweetsController < Api::V1::BaseController
  before_action :get_brand, only: [:create]

  def index
    @promotional_tweets = PromotionalTweet.all
  end

  def create
    ApplicationRecord.transaction do
      post_tweet_service = PostPromotionalTweet.new(promo_tweet_params, @brand)
      @promotional_tweet = post_tweet_service.send!
    end

    render json: @promotional_tweet, each_serializer: PromotionalTweetSerializer
  end

  private

  def promo_tweet_params
    params.permit(:listen_signal_id, :message, :encoded_image)
  end
end
