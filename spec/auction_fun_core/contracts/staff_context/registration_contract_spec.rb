# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::StaffContext::RegistrationContract, type: :contract do
  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:name]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:email]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:phone]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    it_behaves_like "validate_name_contract", :staff
    it_behaves_like "validate_email_contract", :staff
    it_behaves_like "validate_phone_contract", :staff
  end
end
