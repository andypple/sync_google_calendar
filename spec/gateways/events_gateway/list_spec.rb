require 'rails_helper'

RSpec.describe EventsGateway::List do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:gateway) { described_class.new(faraday_client: conn) }

  after do
    Faraday.default_connection = nil
  end

  describe '#fetch' do
    context 'get list calendars successfully' do
      before do
        stubs.get('calendars/primary/events') do
          [
            200,
            {},
            {
              "nextPageToken"=>"NEXT_PAGE_TOKEN",
              "nextSyncToken"=>"NEXT_SYNC_TOKEN",
              "items"=> [
                {
                  "id"=>"0bq00tqb8tmfln",
                  "summary"=>"First meeting",
                }
              ]
            }
          ]
        end
      end

      it do
        result = gateway.fetch
        expect(result.next_page_token).to eq "NEXT_PAGE_TOKEN"
        expect(result.next_sync_token).to eq "NEXT_SYNC_TOKEN"
        expect(result.items.count).to eq 1
        stubs.verify_stubbed_calls
      end
    end
  end
end
