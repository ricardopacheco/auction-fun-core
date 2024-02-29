# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::Processor::StartContract, type: :contract do
  let(:auction) { Factory[:auction, :default_standard] }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when all attributes are blank" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:kind]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when auction_id is not founded on database" do
      let(:attributes) { {auction_id: 2_234_231} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:auction_id]).to include(I18n.t("contracts.errors.custom.not_found"))
      end
    end

    describe "when auction kind is invalid" do
      let(:attributes) { {auction_id: auction.id, auction: "invalid"} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:kind]).to include(
          I18n.t(
            "contracts.errors.included_in?.arg.default",
            list: described_class::KINDS.join(", ")
          )
        )
      end
    end

    describe "stopwatch" do
      let(:auction) { Factory[:auction, :default_penny] }

      context "when kind is penny and stopwatch is blank" do
        let(:attributes) { {auction_id: auction.id, kind: auction.kind} }

        it "expect failure with error message" do
          expect(contract).to be_failure
          expect(contract.errors[:stopwatch]).to include(I18n.t("contracts.errors.filled?"))
        end
      end

      context "when kind is penny and stopwatch is not within the allowed range" do
        let(:attributes) { {auction_id: auction.id, kind: auction.kind, stopwatch: 100} }

        it "expect failure with error message" do
          expect(contract).to be_failure
          expect(contract.errors[:stopwatch]).to include(
            I18n.t("contracts.errors.included_in?.arg.range", list_left: 15, list_right: 60)
          )
        end
      end
    end

    context "when attributes are valid" do
      let(:attributes) { {auction_id: auction.id, kind: auction.kind, stopwatch: 15} }

      it "expect return success" do
        expect(contract).to be_success
        expect(contract.context[:auction]).to be_a(AuctionFunCore::Entities::Auction)
      end
    end
  end
end
