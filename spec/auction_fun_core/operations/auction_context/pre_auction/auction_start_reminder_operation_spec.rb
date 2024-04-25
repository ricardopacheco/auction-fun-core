# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::PreAuction::AuctionStartReminderOperation, type: :operation do
  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:auction) { Factory[:auction, :default_scheduled_standard, started_at: 3.hours.from_now] }
        let(:participant) { Factory[:user] }
        let(:attributes) { {auction_id: auction.id} }

        before do
          Factory[:bid, user_id: participant.id, auction_id: auction.id, value_cents: auction.minimal_bid_cents]
        end

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to include([participant.id])
          expect(matched_failure).to be_nil
        end
      end

      context "when operation happens with failure" do
        let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

        it "expect result matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_nil
          expect(matched_failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call(attributes)" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract is invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect return failure with error messages" do
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract is valid" do
      let(:auction) { Factory[:auction, :default_scheduled_standard, started_at: 3.hours.from_now] }
      let(:attributes) { {auction_id: auction.id} }

      context "when the auction has no participants" do
        it "expect not to schedule a reminder email to the participant" do
          allow(AuctionFunCore::Workers::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailerJob)
            .to receive(:perform_async)

          operation

          expect(AuctionFunCore::Workers::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailerJob)
            .not_to have_received(:perform_async)
        end
      end

      context "when the auction has participants" do
        let(:participant) { Factory[:user] }

        before do
          Factory[:bid, user_id: participant.id, auction_id: auction.id, value_cents: auction.minimal_bid_cents]
        end

        it "expects to schedule a reminder email to the participant" do
          allow(AuctionFunCore::Workers::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailerJob)
            .to receive(:perform_async).with(auction.id, participant.id)

          operation

          expect(AuctionFunCore::Workers::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailerJob)
            .to have_received(:perform_async).with(auction.id, participant.id).once
        end
      end
    end
  end
end
