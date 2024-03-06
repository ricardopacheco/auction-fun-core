# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::BidContext::CreateBidStandardOperation, type: :operation do
  let(:bid_repository) { AuctionFunCore::Repos::BidContext::BidRepository.new }

  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:auction) { Factory[:auction, :default_standard] }
        let(:user) { Factory[:user] }
        let(:attributes) do
          Factory.structs[:bid, user: user, auction: auction]
            .to_h.except(:id, :created_at, :updated_at, :staff, :user)
            .merge!(value_cents: auction.initial_bid_cents * 2)
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
      let(:attributes) { {} }

      it "expect return failure with error messages" do
        expect(operation).to be_failure
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end

      it "expect not persist new bid on database" do
        expect(bid_repository.count).to be_zero

        expect { operation }.not_to change(bid_repository, :count)
      end
    end

    context "when contract are valid" do
      let(:auction) { Factory[:auction, :default_standard] }
      let(:user) { Factory[:user] }
      let(:attributes) do
        Factory.structs[:bid, user: user, auction: auction]
          .to_h.except(:id, :created_at, :updated_at, :staff, :user)
          .merge!(value_cents: auction.initial_bid_cents * 2)
      end

      it "expect persist new bid on database" do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)

        expect { operation }.to change(bid_repository, :count).from(0).to(1)

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end

      it "expect return success without error messages" do
        expect(operation).to be_success
        expect(operation.failure).to be_blank
      end
    end
  end
end
