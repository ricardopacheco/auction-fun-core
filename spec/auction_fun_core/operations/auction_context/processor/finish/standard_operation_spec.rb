# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::Processor::Finish::StandardOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:auction) { Factory[:auction, :default_running_standard, finished_at: Time.current] }

  describe ".call(auction_id, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:attributes) { {auction_id: auction.id} }
        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success.id).to eq(auction.id)
          expect(matched_success.status).to eq("finished")
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

  describe "#call" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract is invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect not change auction status" do
        expect { operation }.not_to change { auction_repository.by_id(auction.id).status }
      end

      it "expect return failure with error messages" do
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract is valid" do
      let(:attributes) { {auction_id: auction.id} }

      it "expect update status auction record on database" do
        expect { operation }
          .to change { auction_repository.by_id(auction.id).status }
          .from("running")
          .to("finished")
      end

      it "expect publish the auction finish event" do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)

        operation

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end

      context "when the auction has a winning bid with other participations" do
        let(:winner) { Factory[:user] }

        before do
          Factory[:bid, auction: auction, value_cents: auction.minimal_bid_cents]
          Factory[:bid, auction: auction, user: winner, value_cents: (auction.minimal_bid_cents * 2)]
        end

        it "expect call winner operation and participant operation jobs" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::PostAuction::WinnerOperationJob)
            .to receive(:perform_async)
          allow(AuctionFunCore::Workers::Operations::AuctionContext::PostAuction::ParticipantOperationJob)
            .to receive(:perform_async)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::PostAuction::WinnerOperationJob)
            .to have_received(:perform_async).once
          expect(AuctionFunCore::Workers::Operations::AuctionContext::PostAuction::ParticipantOperationJob)
            .to have_received(:perform_async).once
        end
      end
    end
  end
end
