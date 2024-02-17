# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Contracts::UserContext::AuthenticationContract, type: :contract do
  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { {} }

      it "expect failure with error messages" do
        expect(contract).to be_failure
        expect(contract.errors[:login]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:password]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when login params are invalid" do
      context "when email is invalid" do
        let(:attributes) { {login: "invalid_email"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:login]).to include(
            I18n.t("contracts.errors.custom.macro.login_format")
          )
        end
      end

      context "when phone is invalid" do
        let(:attributes) { {login: "12345"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:login]).to include(
            I18n.t("contracts.errors.custom.macro.login_format")
          )
        end
      end
    end

    context "with database" do
      context "when login is not found on database" do
        let(:attributes) { {login: "notfound@user.com", password: "example"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:base]).to include(
            I18n.t("contracts.errors.custom.default.login_not_found")
          )
        end
      end

      context "when password doesn't match with storage password on database" do
        let(:user) { Factory[:user] }
        let(:attributes) { {login: user.email, password: "invalid"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:base]).to include(
            I18n.t("contracts.errors.custom.default.login_not_found")
          )
        end
      end
    end

    context "when credentials are valid" do
      let(:user) { Factory[:user] }
      let(:attributes) { {login: user.email, password: "password"} }

      it "expect return success" do
        expect(contract).to be_success
      end
    end
  end
end
