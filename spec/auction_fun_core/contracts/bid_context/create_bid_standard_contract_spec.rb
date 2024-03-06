# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::BidContext::CreateBidStandardContract, type: :contract do
  let(:auction_repo) { described_class.new.auction_repo }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { {} }

      it "expect failure with error messages" do
        expect(contract).to be_failure

        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:user_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:value_cents]).to include(I18n.t("contracts.errors.key?"))
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

      context 'when auction kind is different of "standard"' do
        let(:auction) { Factory[:auction, :default_penny] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect failure with error messages" do
          expect(contract).to be_failure

          expect(contract.errors[:auction_id]).to include(
            I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "standard")
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
      let(:auction) { Factory[:auction, :default_running_standard] }

      context "when auction has no bids" do
        context "when value_cents is less than to auction minimal initial bid" do
          let(:value) { Money.new(auction.initial_bid_cents - 1) }
          let(:attributes) { {auction_id: auction.id, value_cents: value.cents} }

          it "expect failure with error messages" do
            expect(contract).to be_failure

            expect(contract.errors[:value_cents]).to include(
              I18n.t("contracts.errors.gteq?", num: Money.new(auction.initial_bid_cents).to_f)
            )
          end
        end

        context "when value_cents is greather than or equal to to minimal bid" do
          let(:value) { Money.new(auction.initial_bid_cents) }
          let(:attributes) { {auction_id: auction.id, user_id: user.id, value_cents: value.cents} }

          it "expect return success" do
            expect(contract).to be_success
          end
        end
      end

      context "when auction has bids" do
        let(:last_bid) { Money.new(auction.minimal_bid_cents) }
        let!(:bid) { Factory[:bid, auction: auction, value_cents: last_bid.cents] }
        let(:required_minimal_bid) { (last_bid.cents + (last_bid.cents * 0.1)) }

        before do
          auction_repo.update(auction.id, {minimal_bid_cents: required_minimal_bid.to_i})
        end

        context "when value_cents is less than to auction minimal bid value" do
          let(:value_cents) { last_bid.cents - 1 }
          let(:attributes) { {auction_id: auction.id, value_cents: value_cents} }
          let(:required_minimal_bid) { (last_bid.cents + (last_bid.cents * 0.1)) }

          it "expect failure with error messages" do
            expect(contract).to be_failure
            expect(contract.errors[:value_cents]).to include(
              I18n.t("contracts.errors.gteq?", num: Money.new(required_minimal_bid).to_f)
            )
          end
        end

        context "when value_cents is greather than or equal to ten percent of auction minimal bid value" do
          let(:value_cents) { 1_100 }
          let(:attributes) { {auction_id: auction.id, user_id: user.id, value_cents: value_cents} }

          it "expect return success" do
            expect(contract).to be_success
          end
        end
      end
    end
  end
end
