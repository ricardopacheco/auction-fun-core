# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::PostAuction::WinnerOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:winner) { Factory[:user] }
  let(:auction) { Factory[:auction, :default_finished_standard, winner_id: winner.id] }

  describe ".call(auction_id, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:attributes) { {auction_id: auction.id, winner_id: winner.id} }
        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to include(winner)
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
          expect(matched_failure[:winner_id]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract is invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect return failure with error messages" do
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(operation.failure[:winner_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract is valid" do
      let(:attributes) { {auction_id: auction.id, winner_id: winner.id} }

      it "expect send winning email with auction statistics and payment instructions" do
        allow(AuctionFunCore::Workers::Services::Mail::AuctionContext::PostAuction::WinnerMailerJob)
          .to receive(:perform_async).with(auction.id, winner.id)

        operation

        expect(AuctionFunCore::Workers::Services::Mail::AuctionContext::PostAuction::WinnerMailerJob)
          .to have_received(:perform_async).with(auction.id, winner.id).once
      end
    end
  end
end
