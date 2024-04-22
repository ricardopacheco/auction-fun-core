# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Entities::Auction, type: :entity do
  describe "#initial_bid" do
    subject(:auction) { Factory.structs[:auction] }

    it "expect return initial bid as money object" do
      expect(auction.initial_bid).to be_a_instance_of(Money)
    end
  end

  describe "#minimal_bid" do
    subject(:auction) { Factory.structs[:auction] }

    it "expect return minimal bid as money object" do
      expect(auction.minimal_bid).to be_a_instance_of(Money)
    end
  end

  describe "#winner?" do
    context "when there is an associated FK" do
      subject(:auction) { Factory.structs[:auction, :with_winner, winner_id: 1] }

      it "expects to return true when it has a winning user associated." do
        expect(auction.winner?).to be_truthy
      end
    end

    context "when there is no associated FK" do
      subject(:auction) { Factory.structs[:auction] }

      it "expect return a user object" do
        expect(auction.winner?).to be_falsey
      end
    end
  end
end
