# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Operations::AuctionContext::Processor::StartOperation, type: :operation do
  let(:auction_repository) { AuctionFunCore::Repos::AuctionContext::AuctionRepository.new }
  let(:auction) { Factory[:auction, :default_standard, started_at: Time.current] }
  let(:auction_id) { auction.id }
  let(:kind) { auction.kind }
  let(:stopwatch) { 0 }

  describe ".call(attributes, &block)" do
    let(:operation) { described_class }

    context "when block is given" do
      context "when operation happens with success" do
        let(:attributes) do
          {
            auction_id: auction.id,
            kind: auction.kind,
            stopwatch: auction.stopwatch
          }
        end

        it "expect result success matching block" do
          matched_success = nil
          matched_failure = nil

          operation.call(attributes) do |o|
            o.success { |v| matched_success = v }
            o.failure { |f| matched_failure = f }
          end

          expect(matched_success.id).to eq(auction.id)
          expect(matched_success.status).to eq("running")
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
          expect(matched_failure[:auction_id]).to include(I18n.t("contracts.errors.key?"))
        end
      end
    end
  end

  describe "#call" do
    subject(:operation) { described_class.new.call(attributes) }

    context "when contract is invalid" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect not change auction status" do
        expect { operation }.not_to change { auction_repository.by_id(auction.id).status }
      end
    end

    context "when contract is valid" do
      let(:attributes) do
        {
          auction_id: auction.id,
          kind: auction.kind,
          stopwatch: auction.stopwatch
        }
      end

      it "expect update status auction record on database and publish the auction start event" do
        allow(AuctionFunCore::Application[:event]).to receive(:publish)

        expect { operation }.to change { auction_repository.by_id(auction.id).status }.from("scheduled").to("running")

        expect(AuctionFunCore::Application[:event]).to have_received(:publish).once
      end

      context "when auction kind is equal to 'standard'" do
        it "expect create a new job to finish the standard auction" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::StandardOperationJob).to receive(:perform_at)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::StandardOperationJob)
            .to have_received(:perform_at)
            .once
        end
      end

      context "when auction kind is equal to 'closed'" do
        let(:auction) { Factory[:auction, :default_closed, started_at: Time.current] }

        it "expect create a new job to finish the closed auction" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::ClosedOperationJob).to receive(:perform_at)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::ClosedOperationJob)
            .to have_received(:perform_at)
            .once
        end
      end

      context "when auction kind is equal to 'penny'" do
        let(:stopwatch) { 45 }
        let(:old_finished_at) { auction.finished_at.strftime("%Y-%m-%d %H:%M:%S") }
        let(:new_finished_at) { stopwatch.seconds.from_now.strftime("%Y-%m-%d %H:%M:%S") }
        let(:attributes) do
          {
            auction_id: auction.id,
            kind: "penny",
            stopwatch: stopwatch
          }
        end

        before { auction_repository.update(auction.id, kind: "penny") }

        it "expect update finished_at to stopwatch seconds from now" do
          expect { operation }
            .to change { auction_repository.by_id(auction.id).finished_at.strftime("%Y-%m-%d %H:%M:%S") }
            .from(old_finished_at)
            .to(new_finished_at)
        end

        it "expect call the finish penny auction job" do
          allow(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .to receive(:perform_at)

          operation

          expect(AuctionFunCore::Workers::Operations::AuctionContext::Processor::Finish::PennyOperationJob)
            .to have_received(:perform_at)
        end
      end
    end
  end
end
