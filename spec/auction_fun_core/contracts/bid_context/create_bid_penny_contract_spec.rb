# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::BidContext::CreateBidPennyContract, type: :contract do
  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure

        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:user_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "with foreign key user_id param" do
      context "when is a invalid type" do
        let(:attributes) { {user_id: "wrongvalue"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:user_id]).to include(I18n.t("contracts.errors.int?"))
        end
      end

      context "when is not found on database" do
        let(:attributes) { {user_id: rand(10_000..1_000_000)} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:user_id]).to include(I18n.t("contracts.errors.custom.not_found"))
        end
      end
    end

    context "with foreign key auction_id param" do
      context "when a invalid type" do
        let(:attributes) { {auction_id: "wrongvalue"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.int?"))
        end
      end

      context "when is not found on database" do
        let(:attributes) { {auction_id: rand(10_000..1_000_000)} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
        end
      end

      context 'when auction kind is different of "penny"' do
        let(:auction) { Factory[:auction, :default_scheduled_standard] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(
            I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "penny")
          )
        end
      end

      context 'when auction status is not "scheduled" or "running"' do
        let(:auction) { Factory[:auction, :default_finished_standard] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(
            I18n.t("contracts.errors.custom.bids.invalid_status", status: auction.status)
          )
        end
      end
    end

    context "with user balance" do
      let(:bid_cents) { 10_000 }
      let(:user) { Factory[:user] }
      let(:auction) { Factory[:auction, :default_running_penny, initial_bid_cents: bid_cents] }
      let(:attributes) { {auction_id: auction.id, user_id: user.id} }

      context "when does not have enough balance to bid" do
        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:user_id]).to include(
            I18n.t("contracts.errors.custom.bids.insufficient_balance")
          )
        end
      end

      context "when has enough balance to bid" do
        before do
          AuctionFunCore::Repos::UserContext::UserRepository.new.update(
            user.id, balance_cents: (bid_cents * 10)
          )
        end

        it "expect return success" do
          expect(contract).to be_success
        end
      end
    end
  end
end
