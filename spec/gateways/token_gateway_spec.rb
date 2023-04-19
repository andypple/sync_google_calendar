require 'rails_helper'

RSpec.describe TokenGateway do
  let(:gateway) { TokenGateway.new }

  describe '#refresh' do
    let(:url) { 'https://oauth2.googleapis.com/token' }
    let(:params) do
      {
        client_id: nil,
        client_secret: nil,
        refresh_token: 'valid_refresh_token',
        grant_type: 'refresh_token'
      }.to_json
    end
    let(:headers) { { 'Content-Type' => 'application/json' } }

    let(:response) { double('Faraday::Response', body: { access_token: 'new token', expires_in: 60 }.to_json) }

    it do
      expect(Faraday).to receive(:post).with(url, params, headers).and_return(response)
      result = gateway.refresh('valid_refresh_token')

      expect(result[:token]).to eq "new token"
      expect(result[:expires_at].future?).to be_truthy
    end
  end
end
