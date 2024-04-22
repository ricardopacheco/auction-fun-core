# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::BidContext::CreateBidPennyOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:bid_repository) { AuctionFunCore::Repos::BidContext::BidRepository.new }

  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:auction) { Factory[:auction, :default_scheduled_penny] }
        let(:user) { Factory[:user] }
        let(:attributes) do
          Factory.structs[:bid, user: user, auction: auction]
            .to_h.except(:id, :created_at, :updated_at, :staff, :user)
        end

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_a(AuctionFunCore::Entities::Bid)
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

    context "when contract are not valid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect not persist new bid on database" do
        expect(bid_repository.count).to be_zero

        expect { operation }.not_to change(bid_repository, :count)
      end

      it "expect return failure with error messages" do
        expect(operation).to be_failure
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract are valid" do
      let(:auction) { Factory[:auction, :default_scheduled_penny] }
      let(:user) { Factory[:user] }
      let(:attributes) do
        Factory.structs[:bid, user: user, auction: auction]
          .to_h.except(:id, :created_at, :updated_at, :staff, :user)
      end

      it "expect return success without error messages" do
        expect(operation).to be_success
        expect(operation.failure).to be_blank
      end

      it "expect persist new bid on database" do
        expect { operation }.to change(bid_repository, :count).from(0).to(1)
      end

      it "expect dispatch event" do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)

        operation

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end

      context "when an auction has not started" do
        it "expects not to update the auction's 'finished_at' field" do
          expect { operation }.not_to change { auction_repository.by_id(auction.id).finished_at }
        end

        it "expect not reschedule the end of the auction" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .to receive(:perform_at).with(Time, auction.id)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .not_to have_received(:perform_at).with(Time, auction.id)
        end
      end

      context "when an auction was started" do
        let(:auction) { Factory[:auction, :default_running_penny] }
        let(:user) { Factory[:user, :with_balance] }

        it "expects to update the auction's 'finished_at' field and reschedule the end of the auction" do
          expect { operation }.to change { auction_repository.by_id(auction.id).finished_at }
        end

        it "expect reschedule the end of the auction" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .to receive(:perform_at).with(Time, auction.id)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .to have_received(:perform_at).with(Time, auction.id).once
        end
      end
    end
  end
end
