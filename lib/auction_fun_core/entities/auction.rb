# frozen_string_literal: true

module AuctionFunCore
  module Entities
    # Auction Relations class. This return simple objects with attribute readers
    # to represent data in your auction.
    class Auction < ROM::Struct
      INQUIRER_ATTRIBUTES = Relations::Auctions::STATUSES.values.freeze

      # Retrieves the initial bid amount for an auction as a Money object.
      #
      # This method creates and returns a new Money object that represents the initial bid
      # amount required to start bidding in the auction. It utilizes `initial_bid_cents` and
      # `initial_bid_currency` attributes to construct the Money object, ensuring that the amount
      # is correctly represented in the specified currency.
      #
      # @return [Money] Returns a Money object representing the initial bid amount with the specified currency.
      def initial_bid
        Money.new(initial_bid_cents, initial_bid_currency)
      end

      # Retrieves the minimal bid amount for an auction as a Money object.
      #
      # This method creates and returns a new Money object that represents the minimal bid
      # amount required to participate in the auction. It uses `minimal_bid_cents` and
      # `minimal_bid_currency` attributes to construct the Money object.
      #
      # @return [Money] Returns a Money object representing the minimal bid amount with the appropriate currency.
      def minimal_bid
        Money.new(minimal_bid_cents, minimal_bid_currency)
      end

      # Checks if an auction has a winner.
      #
      # This method determines if an auction has a winner based on the presence of a `winner_id`.
      # It returns true if the `winner_id` is present, indicating that the auction has concluded
      # with a winning bidder.
      #
      # @return [Boolean] Returns `true` if there is a winner for the auction, otherwise returns `false`.
      def winner?
        winner_id.present?
      end

      # Checks if an auction has already started.
      #
      # This method determines if an auction has begun based on its status and by comparing
      # the auction's start time (`started_at`) with the current time. An auction is considered
      # started if it is no longer scheduled (i.e., its status is not "scheduled") and
      # the start time (`started_at`) is equal to or before the current time.
      # @return [Boolean] Returns `true` if the auction has already started, otherwise returns `false`.
      def started?
        status != "scheduled" && Time.current > started_at
      end

      # Checks if an auction has not started yet.
      #
      # This method verifies if an auction is still in the "scheduled" status and whether
      # its start time (`started_at`) is still in the future compared to the current time.
      # The auction is considered not started if it is scheduled and the start time
      # has not yet been reached.
      #
      # @return [Boolean] Returns `true` if the auction has not started yet, otherwise returns `false`.
      def not_started?
        status == "scheduled" && Time.current <= started_at
      end
    end
  end
end
