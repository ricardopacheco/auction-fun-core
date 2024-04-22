# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::PostAuction::WinnerContract, type: :contract do
  let(:auction) { Factory[:auction, :default_standard, :with_winner] }
  let(:winner) { auction.winner }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when attributes are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:winner_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when auction is not found on database" do
      let(:attributes) do
        {
          auction_id: 2_234_231,
          winner_id: winner.id
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    context "when winner is not found on database" do
      let(:attributes) do
        {
          auction_id: auction.id,
          winner_id: 2_234_231
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:winner_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    context "when the informed winner is different from the one set in the auction" do
      let(:real_winner) { Factory[:user] }
      let(:fake_winner) { Factory[:user] }
      let(:auction) { Factory[:auction, :default_standard, winner_id: real_winner.id] }
      let(:attributes) do
        {
          auction_id: auction.id,
          winner_id: fake_winner.id
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:winner_id]).to include(I18n.t("wrong", scope: described_class::I18N_SCOPE))
      end
    end

    context "when the informed winner is the same as the one set in the auction" do
      let(:attributes) do
        {
          auction_id: auction.id,
          winner_id: winner.id
        }
      end

      it "expect return sucess" do
        expect(contract).to be_success
        expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
        expect(contract.context[:winner]).to be_a(AuctionFunCore::Entities::User)
      end
    end
  end
end
