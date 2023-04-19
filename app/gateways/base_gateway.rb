require 'faraday_middleware'

class BaseGateway
  def initialize(token: nil, faraday_client: nil)
    @token = token
    @faraday_client = faraday_client
  end

  def base_url
    'https://www.googleapis.com/calendar/v3/'
  end

  def faraday_client
    @faraday_client ||= Faraday.new(base_url) do |conn|
      conn.request :authorization, 'Bearer', token
      conn.request :retry, max: 3
      conn.response :json
      conn.response :logger unless Rails.env.production?
    end
  end

  private

  attr_reader :token
end
