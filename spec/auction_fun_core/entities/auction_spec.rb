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
end
