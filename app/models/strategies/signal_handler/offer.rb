module SignalHandler
  class Offer < SignalHandler::Signal
    def initialize(name, exp_date, user)
      super(name, exp_date, user)
      @signal_type = ListenSignal::Types::OFFER
    end

    def create!
      super(@signal_type)
    end
  end
end
