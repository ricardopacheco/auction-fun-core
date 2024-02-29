# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::Processor::FinishOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:auction) { Factory[:auction, :default_running_standard, finished_at: Time.current] }

  describe ".call(auction_id, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(auction.id) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success.id).to eq(auction.id)
          expect(matched_success.status).to eq("finished")
          expect(matched_failure).to be_nil
        end
      end

      context "when operation happens with failure" do
        let(:auction_id) { nil }

        it "expect result matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(auction_id) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success).to be_nil
          expect(matched_failure[:auction_id]).to include(I18n.t("contracts.errors.filled?"))
        end
      end
    end
  end

  describe "#call" do
    subject(:operation) { described_class.new.call(auction_id) }

    context "when contract is invalid" do
      let(:auction_id) { nil }

      it "expect not change auction status" do
        expect { operation }.not_to change { auction_repository.by_id(auction.id).status }
      end

      it "expect return failure with error messages" do
        expect(operation.failure[:auction_id]).to include(I18n.t("contracts.errors.filled?"))
      end
    end

    context "when contract is valid" do
      let(:auction_id) { auction.id }

      it "expect update status auction record on database" do
        expect { operation }
          .to change { auction_repository.by_id(auction.id).status }
          .from("running")
          .to("finished")
      end

      it "expect publish the auction finish event" do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)

        operation

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end
    end
  end
end
