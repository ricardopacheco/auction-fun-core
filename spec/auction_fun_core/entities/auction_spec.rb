# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Entities::Auction, type: :entity do
  describe "#initial_bid" do
    subject(:auction) { Factory.structs[:auction, :default_scheduled_standard] }

    it "expect return initial bid as money object" do
      expect(auction.initial_bid).to be_a_instance_of(Money)
    end
  end

  describe "#minimal_bid" do
    subject(:auction) { Factory.structs[:auction, :default_scheduled_standard] }

    it "expect return minimal bid as money object" do
      expect(auction.minimal_bid).to be_a_instance_of(Money)
    end
  end

  describe "#winner?" do
    context "when there is an associated FK" do
      subject(:auction) { Factory.structs[:auction, :default_finished_standard, :with_winner, winner_id: 1] }

      it "expects to return true when it has a winning user associated." do
        expect(auction.winner?).to be_truthy
      end
    end

    context "when there is no associated FK" do
      subject(:auction) { Factory.structs[:auction, :default_scheduled_standard] }

      it "expect return a user object" do
        expect(auction.winner?).to be_falsey
      end
    end
  end

  describe "#started?" do
    context "when an auction has not started" do
      subject(:auction) { Factory.structs[:auction, :default_scheduled_standard, started_at: 3.hours.from_now] }

      it "expect return false" do
        expect(auction.started?).to be_falsey
      end
    end

    context "when an auction was started" do
      subject(:auction) { Factory.structs[:auction, :default_running_standard, started_at: 1.minute.ago] }

      it "expect return true" do
        expect(auction.started?).to be_truthy
      end
    end
  end

  describe "#not_started?" do
    context "when an auction was started" do
      subject(:auction) { Factory.structs[:auction, :default_running_standard, started_at: 1.minute.ago] }

      it "expect return false" do
        expect(auction.not_started?).to be_falsey
      end
    end

    context "when an auction has not started" do
      subject(:auction) { Factory.structs[:auction, :default_scheduled_standard, started_at: 3.hours.from_now] }

      it "expect return true" do
        expect(auction.not_started?).to be_truthy
      end
    end
  end
end
