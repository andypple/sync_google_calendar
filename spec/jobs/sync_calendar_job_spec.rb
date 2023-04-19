require 'rails_helper'

RSpec.describe SyncCalendarJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    it "matches with enqueued job" do
      expect {
        described_class.perform_later(1)
      }.to have_enqueued_job.on_queue(:critical)
    end
  end

  describe "#perform" do
    context "user is existed" do
      let(:user) { create(:user) }

      it do
        expect(Calendar::Sync).to receive_message_chain('new.call')
        described_class.perform_now(user.id)
      end
    end

    context "user is not existed" do
      it do
        expect(Calendar::Sync).to_not receive(:new)
        described_class.perform_now(1)
      end
    end
  end
end
