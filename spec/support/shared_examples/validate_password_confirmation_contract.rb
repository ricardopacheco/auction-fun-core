# frozen_string_literal: true

shared_examples "validate_password_confirmation_contract" do |factory_name|
  let(:factory) { Factory[factory_name] }

  context "when password characters are outside the allowed range" do
    let(:attributes) { {password: "password", password_confirmation: "1234567"} }

    it "expect failure with error messages" do
      expect(contract).to be_failure
      expect(contract.errors[:password_confirmation]).to include(
        I18n.t("contracts.errors.custom.default.password_confirmation")
      )
    end
  end
end
