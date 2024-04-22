# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Repos::AuctionContext::AuctionRepository, type: :repo do
  subject(:repo) { described_class.new }

  describe "#all" do
    let!(:auction) { Factory[:auction, :default_scheduled_standard] }

    it "expect return all auctions" do
      expect(repo.all.size).to eq(1)
      expect(repo.all.first.id).to eq(auction.id)
    end
  end

  describe "#count" do
    context "when has not auction on repository" do
      it "expect return zero" do
        expect(repo.count).to be_zero
      end
    end

    context "when has auctions on repository" do
      let!(:auction) { Factory[:auction, :default_scheduled_standard] }

      it "expect return total" do
        expect(repo.count).to eq(1)
      end
    end
  end

  describe "#by_id(id)" do
    context "when id is founded on repository" do
      let!(:auction) { Factory[:auction, :default_scheduled_standard] }

      it "expect return rom object" do
        expect(repo.by_id(auction.id)).to be_a(AuctionFunCore::Entities::Auction)
      end
    end

    context "when id is not found on repository" do
      it "expect return nil" do
        expect(repo.by_id(nil)).to be_nil
      end
    end
  end

  describe "#by_id!(id)" do
    context "when id is founded on repository" do
      let!(:auction) { Factory[:auction, :default_scheduled_standard] }

      it "expect return rom object" do
        expect(repo.by_id(auction.id)).to be_a(AuctionFunCore::Entities::Auction)
      end
    end

    context "when id is not found on repository" do
      it "expect raise exception" do
        expect { repo.by_id!(nil) }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end
end
