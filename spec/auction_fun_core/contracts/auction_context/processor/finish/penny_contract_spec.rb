# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::Processor::Finish::PennyContract, type: :contract do
  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when attributes are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when auction is not found on database" do
      let(:attributes) { {auction_id: rand(10_000..1_000_000)} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    context "when auction kind is not equal to 'penny'" do
      let(:auction) { Factory[:auction, :default_running_standard] }
      let(:attributes) { {auction_id: auction.id} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:base]).to include(
          I18n.t("contracts.errors.custom.auction_context.processor.finish.invalid_kind")
        )
      end
    end

    context "when auction status is not equal to 'running'" do
      let(:auction) { Factory[:auction, :default_paused_standard] }
      let(:attributes) { {auction_id: auction.id} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:base]).to include(
          I18n.t("contracts.errors.custom.auction_context.processor.finish.invalid_status")
        )
      end
    end

    context "when attributes are valid" do
      let(:auction) { Factory[:auction, :default_running_penny] }
      let(:attributes) { {auction_id: auction.id} }

      it "expect return success" do
        expect(contract).to be_success
        expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
      end
    end
  end
end
