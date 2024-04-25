# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Workers::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailerJob, type: :worker do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:user_repository) { AuctionFunCore::Repos::UserContext::UserRepository.new }
  let(:participant) { Factory[:user] }
  let(:auction) { Factory[:auction, :default_finished_standard, :with_winner] }
  let(:auction_start_reminder_mailer) { AuctionFunCore::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailer }
  let(:mailer) { auction_start_reminder_mailer.new(auction, participant) }

  describe "#perform" do
    subject(:worker) { described_class.new }

    context "when attributes are valid" do
      before do
        allow(AuctionFunCore::Repos::AuctionContext::AuctionRepository).to receive(:new).and_return(auction_repository)
        allow(AuctionFunCore::Repos::UserContext::UserRepository).to receive(:new).and_return(user_repository)
        allow(auction_repository).to receive(:by_id!).with(auction.id).and_return(auction)
        allow(user_repository).to receive(:by_id!).with(participant.id).and_return(participant)
        allow(auction_start_reminder_mailer).to receive(:new).with(auction, participant).and_return(mailer)
        allow(mailer).to receive(:deliver).and_return(true)
      end

      it "expect trigger registration mailer service" do
        worker.perform(auction.id, participant.id)

        expect(mailer).to have_received(:deliver).once
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
