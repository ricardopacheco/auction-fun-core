# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module AuctionContext
      ##
      # Abstract base class for removes tuples in auctions table.
      # @abstract
      class DeleteAuction < ROM::Commands::Delete[:sql]
        relation :auctions
        register_as :delete
      end
    end
  end
end
