# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::Processor::UnpauseContract, type: :contract do
  let(:auction) { Factory[:auction, :default_standard] }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when attributes are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when auction status is different to 'paused'" do
      let(:attributes) { {auction_id: auction.id} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(
          I18n.t("contracts.errors.custom.bids.invalid_status")
        )
      end
    end

    context "when auction status is equal to 'paused'" do
      let(:auction) { Factory[:auction, :default_paused_standard] }
      let(:attributes) { {auction_id: auction.id} }

      it "expect return success" do
        expect(contract).to be_success
        expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
      end
    end
  end
end
