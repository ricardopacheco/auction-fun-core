# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Workers::Operations::AuctionContext::PostAuction::WinnerOperationJob, type: :worker do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:auction) { Factory[:auction, :default_standard, :with_winner] }

  describe "#perform" do
    subject(:worker) { described_class.new }

    context "when params are valid" do
      it "expect execute winner mailer service" do
        allow(AuctionFunCore::Workers::Services::Mail::AuctionContext::PostAuction::WinnerMailerJob).to receive(:perform_async)

        worker.perform(auction.id, auction.winner_id)

        expect(AuctionFunCore::Workers::Services::Mail::AuctionContext::PostAuction::WinnerMailerJob).to have_received(:perform_async).once
      end
    end

    context "when an exception occours but retry limit is not reached" do
      before do
        stub_const("::AuctionFunCore::Workers::ApplicationJob::MAX_RETRIES", 1)
        allow(AuctionFunCore::Application[:logger]).to receive(:error)
      end

      it "expect rescue/capture exception and reschedule job" do
        expect { worker.perform(nil, nil) }.to change(described_class.jobs, :size).from(0).to(1)

        expect(AuctionFunCore::Application[:logger]).to have_received(:error).at_least(:once)
      end
    end

    context "when the exception reaches the retry limit" do
      before do
        stub_const("::AuctionFunCore::Workers::ApplicationJob::MAX_RETRIES", 0)
        allow(AuctionFunCore::Application[:logger]).to receive(:error)
      end

      it "expect raise exception and stop retry" do
        expect { worker.perform(nil, nil) }.to raise_error(ROM::TupleCountMismatchError)

        expect(AuctionFunCore::Application[:logger]).to have_received(:error).at_least(:once)
      end
    end
  end
end
