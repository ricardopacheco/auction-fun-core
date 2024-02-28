# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::StaffContext::AuthenticationOperation, type: :operation do
  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:staff) { Factory[:staff] }
        let(:attributes) { {login: staff.email, password: "password"} }

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_a(AuctionFunCore::Entities::Staff)
          expect(matched_failure).to be_nil
        end
      end

      context "when operation happens with failure" do
        let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

        it "expect result matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_nil
          expect(matched_failure[:login]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call(attributes)" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect return failure with error messages" do
        expect(operation).to be_failure
        expect(operation.failure[:login]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract are valid" do
      let(:staff) { Factory[:staff] }
      let(:attributes) { {login: staff.email, password: "password"} }

      before do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)
      end

      it "expect return success" do
        expect(operation).to be_success

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end
    end
  end
end
