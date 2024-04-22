# frozen_string_literal: true

module AuctionFunCore
  module Entities
    # Auction Relations class. This return simple objects with attribute readers
    # to represent data in your auction.
    class Auction < ROM::Struct
      INQUIRER_ATTRIBUTES = Relations::Auctions::STATUSES.values.freeze

      def initial_bid
        Money.new(initial_bid_cents, initial_bid_currency)
      end

      def minimal_bid
        Money.new(minimal_bid_cents, minimal_bid_currency)
      end

      def winner?
        winner_id.present?
      end
    end
  end
end
