# frozen_string_literal: true

shared_examples "validate_name_contract" do |factory_name|
  let(:min) { AuctionFunCore::Business::Configuration::MIN_NAME_LENGTH }
  let(:max) { AuctionFunCore::Business::Configuration::MAX_NAME_LENGTH }
  let(:factory) { Factory[factory_name] }

  context "when the characters in the name are outside the allowed range" do
    let(:attributes) { {name: "abc"} }

    it "expect failure with error messages" do
      expect(subject).to be_failure

      expect(subject.errors[:name]).to include(
        I18n.t("contracts.errors.custom.macro.name_format", min: min, max: max)
      )
    end
  end
end
