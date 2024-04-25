# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::PreAuction::AuctionStartReminderContract, type: :contract do
  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    describe "#call" do
      subject(:contract) { described_class.new.call(attributes) }

      context "when attributes are invalid" do
        let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

        it "expect failure with error messages" do
          expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        end
      end

      context "when auction is not found on database" do
        let(:attributes) { {auction_id: 2_234_231} }

        it "expect failure with error messages" do
          expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
        end
      end

      context "when the auction has already started" do
        let(:auction) { Factory[:auction, :default_finished_standard, started_at: 3.hours.ago] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect failure with error messages" do
          expect(contract.errors[:base]).to include(
            I18n.t("contracts.errors.custom.auction_context.pre_auction.auction_start_reminder.auction_already_started")
          )
        end
      end

      context "when the auction has not started" do
        let(:auction) { Factory[:auction, :default_scheduled_standard, started_at: 3.hours.from_now] }
        let(:attributes) { {auction_id: auction.id} }

        it "expect return success" do
          expect(contract).to be_success
          expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
        end
      end
    end
  end
end
