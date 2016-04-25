require 'twitter'

module Twitter
  module Streaming
    class Connection
      def stream(request, response)
        client_context = OpenSSL::SSL::SSLContext.new
        port           = request.uri.port || Addressable::URI::PORT_MAPPING[request.uri.scheme]
        client         = @tcp_socket_class.new(Resolv.getaddress(request.uri.host), port)
        ssl_client     = @ssl_socket_class.new(client, client_context)

        ssl_client.connect
        request.stream(ssl_client)
        while body = ssl_client.readpartial(1024) # rubocop:disable AssignmentInCondition
          response << body
        end
      end
    end
  end
end

desc "Listens to a user's stream of mentions and direct messages"
task twitter_stream: :environment do
  brand       = Brand.find(ENV['BRAND_ID'])

  while true
    brand.twitter_streaming_client.user do |object|
      case object
      when Twitter::Tweet, Twitter::DirectMessage
        filter = Responders::Twitter::Filter.new(brand, object)
        filter.out_multiple_requests!
        filter.out_users_already_responded_to!
        response = filter.grouped_responses.first.last.first
        TwitterResponseWorker.perform_async(brand.id, response.as_json, true)
      when Twitter::Streaming::StallWarning
        warn "Falling behind!"
      end
    end
  end
end
