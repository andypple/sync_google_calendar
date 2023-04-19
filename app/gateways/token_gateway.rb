class TokenGateway
  def refresh(refresh_token) # rubocop:disable Metrics/MethodLength
    response = Faraday.post(
      refresh_url,
      {
        client_id: Rails.application.credentials.dig(:google, :client_id),
        client_secret: Rails.application.credentials.dig(:google, :client_secret),
        refresh_token: refresh_token,
        grant_type: 'refresh_token'
      }.to_json,
      'Content-Type' => 'application/json'
    )
    result = JSON.parse(response.body).with_indifferent_access
    {
      token: result[:access_token],
      expires_at: result[:expires_in].seconds.from_now
    }
  end

  private

  def refresh_url
    'https://oauth2.googleapis.com/token'
  end
end
