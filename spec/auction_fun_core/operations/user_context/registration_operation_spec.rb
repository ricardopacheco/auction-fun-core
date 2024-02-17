# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::UserContext::RegistrationOperation, type: :operation do
  let(:user_repository) { AuctionFunCore::Repos::UserContext::UserRepository.new }

  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:attributes) do
          Factory.structs[:user]
            .to_h
            .except(:id, :created_at, :updated_at, :password_digest)
            .merge!(password: "password", password_confirmation: "password")
        end

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_a(AuctionFunCore::Entities::User)
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
          expect(matched_failure.errors.to_h[:name]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract are not valid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect not persist new user on database" do
        expect(user_repository.count).to be_zero

        expect { operation }.not_to change(user_repository, :count)
      end

      it "expect return failure with error messages" do
        expect(operation).to be_failure
        expect(operation.failure.errors).to be_present
      end
    end

    context "when contract are valid" do
      let(:attributes) do
        Factory.structs[:user]
          .to_h
          .except(:id, :created_at, :updated_at, :password_digest)
          .merge!(password: "password", password_confirmation: "password")
      end

      before do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)
      end

      it "expect persist new user on database and dispatch event registration" do
        expect { operation }.to change(user_repository, :count).from(0).to(1)

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end

      it "expect return success without error messages" do
        expect(operation).to be_success
        expect(operation.failure).to be_blank
      end
    end
  end
end
