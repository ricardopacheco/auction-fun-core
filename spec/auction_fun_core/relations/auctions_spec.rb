# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Relations::Auctions, type: :relations do
  subject(:relation) { AuctionFunCore::Application[:container].relations[:auctions] }

  describe "#all(page = 1, per_page = 10, options = { bidders_count: 3 })" do
    subject(:object) { relation.all }

    context "when page argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.all(nil, 10) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    context "when per_page argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.all(1, nil) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    it "expect include pagination on query" do
      expect(relation.all.dataset.sql).to include("LIMIT 10 OFFSET 0")
    end

    context "when there are no auctions available" do
      subject(:results) { relation.all.to_a }

      it "expect return empty data" do
        expect(results).to eq(Dry::Core::Constants::EMPTY_ARRAY)
      end
    end

    context "when there is an auction available without bids" do
      subject(:result) { relation.all.first }

      let!(:auction) { Factory[:auction, :default_scheduled_standard] }

      it "expect return auction attributes with empty bids" do
        expect(result).to be_a_instance_of(ROM::OpenStruct)
        expect(result.bids).to eq({
          "current" => auction.initial_bid_cents,
          "minimal" => auction.minimal_bid_cents,
          "bidders" => Dry::Core::Constants::EMPTY_ARRAY
        })
        expect(result.description).to eq(auction.description)
        expect(result.finished_at).to eq(auction.finished_at)
        expect(result.id).to eq(auction.id)
        expect(result.initial_bid_cents).to eq(auction.initial_bid_cents)
        expect(result.kind).to eq(auction.kind)
        expect(result.started_at).to eq(auction.started_at)
        expect(result.status).to eq(auction.status)
        expect(result.stopwatch).to eq(auction.stopwatch)
        expect(result.title).to eq(auction.title)
        expect(result.total_bids).to be_zero
      end
    end

    context "when there is an auction available with bids" do
      subject(:result) { relation.all.first }

      let!(:auction) { Factory[:auction, :default_scheduled_standard] }
      let!(:winner) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction attributes with bids info" do
        expect(result).to be_a_instance_of(ROM::OpenStruct)
        expect(result.bids.to_h).to include({
          "current" => bid.value_cents,
          "minimal" => auction.minimal_bid_cents,
          "bidders" => [{
            "id" => bid.id,
            "user_id" => winner.id,
            "name" => winner.name,
            "value" => bid.value_cents,
            "date" => bid.created_at.strftime("%Y-%m-%dT%H:%M:%S.%6N")
          }]
        })
        expect(result.description).to eq(auction.description)
        expect(result.finished_at).to eq(auction.finished_at)
        expect(result.id).to eq(auction.id)
        expect(result.initial_bid_cents).to eq(auction.initial_bid_cents)
        expect(result.kind).to eq(auction.kind)
        expect(result.started_at).to eq(auction.started_at)
        expect(result.status).to eq(auction.status)
        expect(result.stopwatch).to eq(auction.stopwatch)
        expect(result.title).to eq(auction.title)
        expect(result.total_bids).to eq(1)
      end
    end
  end

  describe "#info(auction_id, options = { bidders_count: 3 })" do
    subject(:object) { relation.info(auction_id) }

    let(:auction) { Factory[:auction, :default_scheduled_standard] }
    let(:auction_id) { auction.id }

    context "when there are no auctions available" do
      subject(:result) { relation.info(2_234_231).one }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is an auction available without bids" do
      subject(:result) { relation.info(auction_id).one }

      it "expect return auction attributes with empty bids" do
        expect(result).to be_a_instance_of(ROM::OpenStruct)
        expect(result.bids).to eq({
          "current" => auction.initial_bid_cents,
          "minimal" => auction.minimal_bid_cents,
          "bidders" => Dry::Core::Constants::EMPTY_ARRAY
        })
        expect(result.description).to eq(auction.description)
        expect(result.finished_at).to eq(auction.finished_at)
        expect(result.id).to eq(auction.id)
        expect(result.initial_bid_cents).to eq(auction.initial_bid_cents)
        expect(result.kind).to eq(auction.kind)
        expect(result.started_at).to eq(auction.started_at)
        expect(result.status).to eq(auction.status)
        expect(result.stopwatch).to eq(auction.stopwatch)
        expect(result.title).to eq(auction.title)
        expect(result.total_bids).to be_zero
      end
    end

    context "when there is an auction available with bids" do
      subject(:result) { relation.all.first }

      let!(:auction) { Factory[:auction, :default_scheduled_standard] }
      let!(:winner) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction attributes with bids info" do
        expect(result).to be_a_instance_of(ROM::OpenStruct)
        expect(result.bids.to_h).to include({
          "current" => bid.value_cents,
          "minimal" => auction.minimal_bid_cents,
          "bidders" => [{
            "id" => bid.id,
            "user_id" => winner.id,
            "name" => winner.name,
            "value" => bid.value_cents,
            "date" => bid.created_at.strftime("%Y-%m-%dT%H:%M:%S.%6N")
          }]
        })
        expect(result.description).to eq(auction.description)
        expect(result.finished_at).to eq(auction.finished_at)
        expect(result.id).to eq(auction.id)
        expect(result.initial_bid_cents).to eq(auction.initial_bid_cents)
        expect(result.kind).to eq(auction.kind)
        expect(result.started_at).to eq(auction.started_at)
        expect(result.status).to eq(auction.status)
        expect(result.stopwatch).to eq(auction.stopwatch)
        expect(result.title).to eq(auction.title)
        expect(result.total_bids).to eq(1)
      end
    end
  end

  describe "#load_standard_auction_winners_and_participants(auction_id)" do
    subject(:result) { relation.load_standard_auction_winners_and_participants(auction.id).one }

    context "when there are no auctions available" do
      subject(:result) { relation.load_standard_auction_winners_and_participants(2_234_231).one }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is an auction available without bids" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }

      it "expect return auction data without winner and participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to be_zero
        expect(result.winner_id).to be_nil
      end
    end

    context "when the auction has only one bid (winner)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner and no participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(1)
        expect(result.winner_id).to eq(winner.id)
      end
    end

    context "when the auction has more than one bid (winner and participants)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:participant) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: participant, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner with participants" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to include(participant.id)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(2)
        expect(result.winner_id).to eq(winner.id)
      end
    end
  end

  describe "#load_penny_auction_winners_and_participants(auction_id)" do
    subject(:result) { relation.load_penny_auction_winners_and_participants(auction.id).one }

    context "when there are no auctions available" do
      subject(:result) { relation.load_penny_auction_winners_and_participants(2_234_231).one }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is an auction available without bids" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }

      it "expect return auction data without winner and participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to be_zero
        expect(result.winner_id).to be_nil
      end
    end

    context "when the auction has only one bid (winner)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner and no participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(1)
        expect(result.winner_id).to eq(winner.id)
      end
    end

    context "when the auction has more than one bid (winner and participants)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:participant) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: participant, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner with participants" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to include(participant.id)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(2)
        expect(result.winner_id).to eq(winner.id)
      end
    end
  end

  describe "#load_closed_auction_winners_and_participants(auction_id)" do
    subject(:result) { relation.load_closed_auction_winners_and_participants(auction.id).one }

    context "when there are no auctions available" do
      subject(:result) { relation.load_closed_auction_winners_and_participants(2_234_231).one }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is an auction available without bids" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }

      it "expect return auction data without winner and participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to be_zero
        expect(result.winner_id).to be_nil
      end
    end

    context "when the auction has only one bid (winner)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner and no participants info" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to eq(Dry::Core::Constants::EMPTY_ARRAY)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(1)
        expect(result.winner_id).to eq(winner.id)
      end
    end

    context "when the auction has more than one bid (winner and participants)" do
      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:participant) { Factory[:user] }
      let!(:bid) do
        Factory[:bid, auction: auction, user: participant, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
        Factory[:bid, auction: auction, user: winner, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction data with winner with participants" do
        expect(result.id).to eq(auction.id)
        expect(result.kind).to eq(auction.kind)
        expect(result.participant_ids).to include(participant.id)
        expect(result.status).to eq(auction.status)
        expect(result.total_bids).to eq(2)
        expect(result.winner_id).to eq(winner.id)
      end
    end
  end

  describe "#load_winner_statistics(auction_id, winner_id)" do
    context "when auction_id argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.load_winner_statistics(nil, 10) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    context "when winner_id argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.load_winner_statistics(1, nil) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    context "when there are no auctions available" do
      subject(:result) { relation.load_winner_statistics(2_234_231, winner.id).one }

      let(:winner) { Factory[:user] }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is no bid" do
      subject(:result) { relation.load_winner_statistics(auction.id, winner.id).one }

      let(:auction) { Factory[:auction, :default_finished_standard] }
      let(:winner) { Factory[:user] }

      it "expect return auction attributes without winner and without participants" do
        expect(result.id).to eq(auction.id)
        expect(result.auction_total_bids).to be_zero
        expect(result.winner_total_bids).to be_zero
        expect(result.winner_bid).to be_nil
      end
    end

    context "when there is at least one bid" do
      subject(:result) { relation.load_winner_statistics(auction.id, winner.id).one }

      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:winner_bid_value) { auction.minimal_bid_cents * 2 }
      let!(:participant) { Factory[:user] }
      let!(:participant_bid) do
        Factory[:bid, auction: auction, user: participant, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end
      let!(:winner_bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: winner_bid_value, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction attributes without winner and without participants" do
        expect(result.id).to eq(auction.id)
        expect(result.auction_total_bids).to eq(2)
        expect(result.winner_total_bids).to eq(1)
        expect(result.winner_bid).to eq(winner_bid_value)
      end
    end
  end

  describe "#load_participant_statistics(auction_id, participant_id)" do
    context "when auction_id argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.load_participant_statistics(nil, 10) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    context "when participant_id argument is a invalid input" do
      it "expect raise exception" do
        expect { relation.load_participant_statistics(1, nil) }.to raise_error(RuntimeError, "Invalid argument")
      end
    end

    context "when there are no auctions available" do
      subject(:result) { relation.load_participant_statistics(2_234_231, winner.id).one }

      let(:winner) { Factory[:user] }

      it "expect return empty data" do
        expect(result).to be_blank
      end
    end

    context "when there is no bid" do
      subject(:result) { relation.load_participant_statistics(auction.id, participant.id).one }

      let(:auction) { Factory[:auction, :default_finished_standard] }
      let(:participant) { Factory[:user] }

      it "expect return auction attributes without winner and without participants" do
        expect(result.id).to eq(auction.id)
        expect(result.auction_total_bids).to be_zero
        expect(result.winner_total_bids).to be_zero
        expect(result.winner_bid).to be_nil
      end
    end

    context "when there is at least one bid" do
      subject(:result) { relation.load_participant_statistics(auction.id, participant.id).one }

      let!(:auction) { Factory[:auction, :default_finished_standard] }
      let!(:winner) { Factory[:user] }
      let!(:winner_bid_value) { auction.minimal_bid_cents * 2 }
      let!(:participant) { Factory[:user] }
      let!(:participant_bid) do
        Factory[:bid, auction: auction, user: participant, value_cents: auction.minimal_bid_cents, value_currency: auction.minimal_bid_currency]
      end
      let!(:winner_bid) do
        Factory[:bid, auction: auction, user: winner, value_cents: winner_bid_value, value_currency: auction.minimal_bid_currency]
      end

      it "expect return auction attributes without winner and without participants" do
        expect(result.id).to eq(auction.id)
        expect(result.auction_total_bids).to eq(2)
        expect(result.winner_total_bids).to eq(1)
        expect(result.winner_bid).to eq(winner_bid_value)
      end
    end
  end
end
