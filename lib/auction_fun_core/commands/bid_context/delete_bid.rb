# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module BidContext
      ##
      # Abstract base class for removes tuples in bids table.
      # @abstract
      class DeleteBid < ROM::Commands::Delete[:sql]
        relation :bids
        register_as :delete
      end
    end
  end
end
