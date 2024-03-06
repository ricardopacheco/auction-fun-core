# frozen_string_literal: true

shared_examples "validate_stopwatch_contract" do
  let(:min) { AuctionFunCore::Business::Configuration::AUCTION_STOPWATCH_MIN_VALUE }
  let(:max) { AuctionFunCore::Business::Configuration::AUCTION_STOPWATCH_MAX_VALUE }

  context "when kind is penny and stopwatch is blank" do
    let(:attributes) { {auction_id: auction.id, kind: auction.kind} }

    it "expect failure with error message" do
      expect(contract).to be_failure
      expect(contract.errors[:stopwatch]).to include(I18n.t("contracts.errors.filled?"))
    end
  end

  context "when kind is penny and stopwatch is not within the allowed range" do
    let(:attributes) do
      {
        auction_id: auction.id,
        kind: auction.kind,
        stopwatch: max + 1
      }
    end

    it "expect failure with error message" do
      expect(contract).to be_failure
      expect(contract.errors[:stopwatch]).to include(
        I18n.t("contracts.errors.included_in?.arg.range", list_left: min, list_right: max)
      )
    end
  end
end
