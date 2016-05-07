module Responders
  module Twitter
    class Listener
      HASHTAGS_TO_LISTEN_TO       = {
        'somehashtag' => {
          'text_response' => 'Check out this puppy!',
          'image'         => 'puppy_cuteness.gif',
        },
        'somehashtagwithoutimage' => {
          'text_response' => 'Check out this text response!',
        },
      }

      class << self
        def process_messages(brand_id)
          brand  = Brand.find_with_trackers(brand_id)
          client = brand.twitter_rest_client

          tweet_tracker = brand.tweet_tracker
          dm_tracker    = brand.twitter_dm_tracker

          mentions_timeline_options = build_timeline_options(tweet_tracker)
          dm_timeline_options       = build_timeline_options(dm_tracker)

          direct_messages = client.direct_messages_received(dm_timeline_options)
          tweets          = client.mentions_timeline(mentions_timeline_options)

          UpdateTrackerWorker.perform_async(tweet_tracker.id, tweet_tracker.class.to_s, tweets.map(&:id))
          UpdateTrackerWorker.perform_async(dm_tracker.id, dm_tracker.class.to_s, direct_messages.map(&:id))

          filter = Filter.new(brand, direct_messages.concat(tweets))
          filter.out_multiple_requests!
          filter.out_users_already_responded_to!

          respond_to_messages(filter.grouped_responses, brand)
        end

        private

        # @param grouped_responses [Hash]
        # @param brand             [Brand]
        def respond_to_messages(grouped_responses, brand)
          grouped_responses.each do |_, twitter_responses|
            twitter_responses.each do |twitter_response|
              TwitterResponseWorker.perform_async(brand.id, twitter_response.as_json)
            end
          end
        end

        # @param  [TwitterTracker|TwitterDirectMessageTracker]
        # @return [Hash]
        def build_timeline_options(timeline_tracker)
          options = {
            count:    TimelineHelper::API_TIMELINE_LIMIT,
            since_id: timeline_tracker.since_id
          }

          options.merge!(max_id: timeline_tracker.max_id) unless timeline_tracker.max_id.nil?

          options
        end
      end
    end
  end
end
