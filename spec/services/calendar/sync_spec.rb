require 'rails_helper'

RSpec.describe Calendar::Sync do
  describe '#call' do
    let(:user) { create(:user) }
    let(:service) { described_class.new(user) }
    let(:token_refresher) { double(TokenRefresher, call: nil) }

    before do
      expect(TokenRefresher).to receive(:new).and_return(token_refresher).at_least(:once)
      expect(token_refresher).to receive(:call).at_least(:once)
    end

    context 'events are available' do
      let(:items) do
        [
          {
            'kind' => "calendar#event",
            'id' => 'GID_UNIQUE',
            'summary' => 'Weekend coding',
            'description' => 'You are invited',
            'start' => { 'date_time' => '2021-08-25T16:00:00+07:00', time_zone: 'UTC' },
            'end' => { 'date_time' => '2021-08-25T17:00:00+07:00' }
          },
          {
            'kind' => 'not event type'
          }
        ].map(&:with_indifferent_access)
      end
      let(:result) { double(EventsGateway::List, next_page_token: nil, next_sync_token: 'valid_token', items: items) }

      before do
        allow(EventsGateway::List).to receive_message_chain('new.fetch').and_return(result)
        service.call
      end

      it 'saves valid events into database' do
        expect(user.events.count).to eq 1
        expect(user.events.last.gid).to eq 'GID_UNIQUE'
      end

      it 'ingores existed gid records' do
        service.call
        expect(user.events.count).to eq 1
      end

      it 'saves latest sync info to database' do
        expect(user.sync_info.sync_token).to eq 'valid_token'
      end
    end

    context 'full sync' do
      let(:events_gateway) { double(EventsGateway::List) }
      let!(:sync_info) { create(:sync_info, user: user, sync_token: 'valid_sync_token') }

      let(:paginated_result) { double(EventsGateway::List, next_page_token: 'valid_page_token', next_sync_token: 'valid_sync_token', items: []) }
      let(:end_result) { double(EventsGateway::List, next_page_token: nil, next_sync_token: 'valid_sync_token', items: []) }

      it 'fetches events with sync token and page token' do
        expect(EventsGateway::List).to receive(:new).and_return(events_gateway).twice
        expect(events_gateway)
          .to receive(:fetch).with(sync_token: 'valid_sync_token').and_return(paginated_result)
        expect(events_gateway)
          .to receive(:fetch).with(page_token: 'valid_page_token').and_return(end_result)
        service.call
      end
    end

    context 'continuous sync' do
      let(:events_gateway) { double(EventsGateway::List) }
      let!(:sync_info) { create(:sync_info, user: user, page_token: 'valid_page_token') }

      let(:end_result) { double(EventsGateway::List, next_page_token: nil, next_sync_token: 'valid_sync_token', items: []) }

      it 'fetches events with page token' do
        expect(EventsGateway::List).to receive(:new).and_return(events_gateway)
        expect(events_gateway)
          .to receive(:fetch).with(page_token: 'valid_page_token').and_return(end_result)
        service.call
      end
    end
  end
end
