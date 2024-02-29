# frozen_string_literal: true

module AuctionFunCore
  module Entities
    # Auction Relations class. This return simple objects with attribute readers
    # to represent data in your auction.
    class Auction < ROM::Struct
      def initial_bid
        Money.new(initial_bid_cents, initial_bid_currency)
      end

      def minimal_bid
        Money.new(minimal_bid_cents, minimal_bid_currency)
      end
    end
  end
end
