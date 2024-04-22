# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Repos::BidContext::BidRepository, type: :repo do
  subject(:repo) { described_class.new }

  describe "#create" do
    let(:auction) { Factory[:auction, :default_scheduled_standard] }
    let(:user) { Factory[:user] }

    let(:bid) do
      repo.create(
        auction_id: auction.id,
        user_id: user.id,
        value_cents: auction.minimal_bid_cents
      )
    end

    it "expect create a new bid on repository" do
      expect(bid).to be_a(AuctionFunCore::Entities::Bid)
      expect(bid.auction_id).to eq(auction.id)
      expect(bid.user_id).to eq(user.id)
      expect(bid.value_cents).to eq(auction.minimal_bid_cents)
      expect(bid.created_at).not_to be_blank
      expect(bid.updated_at).not_to be_blank
    end
  end

  describe "#count" do
    context "when has not bids on repository" do
      it "expect return zero" do
        expect(repo.count).to be_zero
      end
    end

    context "when has bids on repository" do
      let!(:bid) { Factory[:bid] }

      it "expect return total" do
        expect(repo.count).to eq(1)
      end
    end
  end

  describe "#exists?(conditions)" do
    context "when conditions finds any record" do
      let(:bid) { Factory[:bid] }
      let(:conditions) { {auction_id: bid.auction_id, user_id: bid.user_id} }

      it "expect return true" do
        expect(repo).to exist(conditions)
      end
    end

    context "when conditions does not find any record" do
      let(:conditions) { {id: -1} }

      it "expect return false" do
        expect(repo).not_to exist(conditions)
      end
    end
  end
end
