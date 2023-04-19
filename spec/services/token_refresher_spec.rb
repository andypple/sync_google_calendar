require 'rails_helper'

RSpec.describe TokenRefresher do
  describe '#call' do
    let(:service) { described_class.new(user) }

    context 'token is expired' do
      let(:user) { create(:user, refresh_token: 'token', expires_at: 10.minutes.ago) }
      let(:result) { { 'token' => 'new token', 'expires_at' => 60.minutes.from_now } }

      it 'refreshes new token' do
        expect_any_instance_of(TokenGateway)
          .to receive(:refresh).with(user.refresh_token).and_return(result)
        service.call
        expect(user.reload.slice(:token, :expires_at)).to eq result
      end
    end

    context 'token is not expired' do
      let(:user) { create(:user, refresh_token: 'token', token: 'current_token', expires_at: 10.minutes.from_now) }

      it 'preserves current token' do
        expect_any_instance_of(TokenGateway).to_not receive(:refresh)
        service.call
        expect(user.reload.token).to eq 'current_token'
      end
    end
  end
end
