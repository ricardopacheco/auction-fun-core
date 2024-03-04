# frozen_string_literal: true

shared_examples "validate_stopwatch_contract" do
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
