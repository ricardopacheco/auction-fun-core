# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::UserContext::EmailConfirmationContract, type: :contract do
  let(:generate_email_confirmation_token) { AuctionFunCore::Business::TokenService.generate_email_token }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:email_confirmation_token]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when email_confirmation_token is present" do
      context "when token is not found on database" do
        let(:attributes) { {email_confirmation_token: SecureRandom.hex(3)} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:email_confirmation_token]).to include(
            I18n.t("contracts.errors.custom.default.not_found")
          )
        end
      end

      context "when credentials are valid but user is inactive" do
        let(:user) { Factory[:user, :inactive, :with_email_confirmation_token] }
        let(:attributes) { {email_confirmation_token: user.email_confirmation_token} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:base]).to include(
            I18n.t("contracts.errors.custom.default.inactive_account")
          )
        end
      end
    end

    context "when email_confirmation_token is valid" do
      let(:user) { Factory[:user, :unconfirmed, :with_email_confirmation_token] }
      let(:attributes) { {email_confirmation_token: user.email_confirmation_token} }

      it "expect return success" do
        expect(contract).to be_success
      end
    end
  end
end
