require 'faraday'
require 'json'

module EventsGateway
  class List < BaseGateway
    def fetch(sync_token: nil, page_token: nil)
      response = faraday_client.get(
        path, {
          singleEvents: true,
          syncToken: sync_token,
          pageToken: page_token,
          maxResults: 25
        }
      )
      @response = response.body.deep_transform_keys!(&:underscore).with_indifferent_access
      self
    end

    def next_page_token
      response[:next_page_token]
    end

    def next_sync_token
      response[:next_sync_token]
    end

    def items
      response[:items]
    end

    private

    attr_reader :response

    def path
      'calendars/primary/events'
    end
  end
end
