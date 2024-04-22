# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::CreateOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }

  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:staff) { Factory[:staff] }
        let(:attributes) do
          Factory.structs[:auction, :default_scheduled_standard, staff: staff]
            .to_h.except(:id, :created_at, :updated_at, :staff)
        end

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_a(AuctionFunCore::Entities::Auction)
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
          expect(matched_failure[:title]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract are invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect not persist new auction on database" do
        expect(auction_repository.count).to be_zero

        expect { operation }.not_to change(auction_repository, :count)
      end

      it "expect return failure with error messages" do
        expect(operation).to be_failure
        expect(operation.failure[:title]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "when contract are valid" do
      let(:staff) { Factory[:staff] }
      let(:attributes) do
        Factory.structs[:auction, :default_scheduled_standard, staff: staff]
          .to_h.except(:id, :created_at, :updated_at, :staff)
      end

      before do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)
        allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::StartOperationJob)
          .to receive(:perform_at)
      end

      it "expect return success creating auction on database with correct status and dispatch event and processes" do
        expect { operation }.to change(auction_repository, :count).from(0).to(1)

        expect(operation).to be_success
        expect(operation.success.status).to eq("scheduled")
        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
        expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::StartOperationJob)
          .to have_received(:perform_at)
          .once
      end
    end
  end
end
