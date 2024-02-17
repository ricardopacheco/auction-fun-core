# frozen_string_literal: true

shared_examples "validate_password_contract" do |factory_name|
  let(:min) { AuctionFunCore::Contracts::ApplicationContract::MIN_PASSWORD_LENGTH }
  let(:max) { AuctionFunCore::Contracts::ApplicationContract::MAX_PASSWORD_LENGTH }
  let(:factory) { Factory[factory_name] }

  context "when password characters are outside the allowed range" do
    let(:attributes) { {password: "123", password_confirmation: "123"} }

    it "expect failure with error messages" do
      expect(contract).to be_failure
      expect(contract.errors[:password]).to include(
        I18n.t("contracts.errors.custom.macro.password_format", min: min, max: max)
      )
    end
  end
end
