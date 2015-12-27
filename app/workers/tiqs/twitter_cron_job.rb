class TwitterCronJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :retry => false

  recurrence backfill: false do
    hourly.minute_of_hour(*(0...60).to_a)
  end

  def perform(last_occurrence, current_occurrence)
    TwitterListener.process_user_tweets(1)
  end
end