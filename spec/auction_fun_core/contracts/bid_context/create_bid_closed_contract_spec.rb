# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::BidContext::CreateBidClosedContract, type: :contract do
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

      context "when user has already placed a bid on the auction" do
        let(:user) { Factory[:user] }
        let(:auction) { Factory[:auction, :default_running_closed] }
        let(:bid) { Factory[:bid, user: user, auction: auction, value_cents: auction.initial_bid_cents] }
        let(:attributes) { {auction_id: auction.id, user_id: user.id, value_cents: (bid.value_cents * 2)} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:user_id]).to include(I18n.t("contracts.errors.custom.bids.already_bidded"))
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

      context 'when auction kind is different of "closed"' do
        let(:auction) { Factory[:auction, :default_penny] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(
            I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "closed")
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

    context "with value_cents param" do
      let(:user) { Factory[:user] }
      let(:auction) { Factory[:auction, :default_running_closed] }

      context "when value_cents is less than to auction initial bid" do
        let(:value) { Money.new(auction.initial_bid_cents - 1) }
        let(:attributes) { {auction_id: auction.id, user_id: user.id, value_cents: value.cents} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:value_cents]).to include(
            I18n.t("contracts.errors.gteq?", num: Money.new(auction.initial_bid_cents).to_f)
          )
        end
      end

      context "when value_cents is greater than or equal to auction initial bid" do
        let(:value) { Money.new(auction.initial_bid_cents) }
        let(:attributes) { {auction_id: auction.id, user_id: user.id, value_cents: value.cents} }

        it "expect return success without error messages" do
          expect(contract).to be_success
        end
      end
    end
  end
end
