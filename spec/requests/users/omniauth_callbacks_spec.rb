require 'rails_helper'

RSpec.describe "/users/auth/:provider/callbacks", type: :request do
  describe "GET /users/auth/google_oauth2/callbacks" do
    before do
      OmniAuth.config.test_mode = true
    end

    context 'authenticates successfuly' do
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
      let!(:user) { create(:user, email: auth.dig('info', 'email')) }

      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth)
        expect(SyncCalendarJob).to receive(:perform_later).with(user.id)

        get '/users/auth/google_oauth2/callback'
      end

      it do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'authenticates unsuccessfuly' do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          'provider' => 'wrong provider',
        })
        get '/users/auth/google_oauth2/callback'
      end

      it do
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
