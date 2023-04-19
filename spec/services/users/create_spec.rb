require 'rails_helper'

RSpec.describe Users::Create do
  describe '#call' do
    let(:service) { described_class.new(auth) }

    context 'create user from google auth successfully' do
      let(:auth) do
        {
          'provider' => 'google_oauth2',
          'info' => { 'email' => 'andypple83@gmail.com' },
          'credentials' => {
            'token' => 'ya29.a0ARrdaM89Ov5KOdr',
            'refresh_token' => '1//0ePYYPJkm3FrOCgYI',
            'expires_at' => 1.day.from_now.to_i
          }
        }
      end

      context 'user is not existed' do
        it 'creates new user with auth info' do
          result = service.call
          expect(result).to be_persisted
          expect(result.email).to eq auth.dig('info', 'email')

          expect(result.token).to eq auth.dig('credentials', 'token')
          expect(result.refresh_token).to eq auth.dig('credentials', 'refresh_token')
          expect(result.expires_at.to_i).to eq auth.dig('credentials', 'expires_at')
        end
      end

      context 'user is existed' do
        let!(:user) { create(:user, email: auth.dig('info', 'email')) }

        it 'updates credentials' do
          result = service.call
          expect(result).to eq user

          expect(result.token).to eq auth.dig('credentials', 'token')
          expect(result.refresh_token).to eq auth.dig('credentials', 'refresh_token')
          expect(result.expires_at.to_i).to eq auth.dig('credentials', 'expires_at')
        end
      end
    end

    context 'can not create user' do
      context 'provider is not google_oauth2' do
        let(:auth) { { 'provider' => 'Not google_oauth2' } }

        specify { expect(service.call).to be_nil }
      end
    end
  end
end
