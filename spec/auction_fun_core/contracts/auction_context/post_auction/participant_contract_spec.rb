# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::PostAuction::ParticipantContract, type: :contract do
  let(:auction) { Factory[:auction, :default_finished_standard, :with_winner] }
  let(:participant) { Factory[:user] }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when attributes are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:participant_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when auction is not found on database" do
      let(:attributes) do
        {
          auction_id: 2_234_231,
          participant_id: participant.id
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    context "when participant is not found on database" do
      let(:attributes) do
        {
          auction_id: auction.id,
          participant_id: 2_234_231
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:participant_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    context "when the user did not bid in the auction" do
      let(:attributes) do
        {
          auction_id: auction.id,
          participant_id: participant.id
        }
      end

      it "expect failure with error messages" do
        expect(contract.errors[:participant_id]).to include(I18n.t("none", scope: described_class::I18N_SCOPE))
      end
    end

    context "when the user placed at least one bid in the auction" do
      let(:attributes) do
        {
          auction_id: auction.id,
          participant_id: participant.id
        }
      end

      before do
        Factory[:bid, auction: auction, user_id: participant.id, value_cents: auction.minimal_bid_cents]
      end

      it "expect return sucess" do
        expect(contract).to be_success
        expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
        expect(contract.context[:participant]).to be_a(AuctionFunCore::Entities::User)
      end
    end
  end
end
