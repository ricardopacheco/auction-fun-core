# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module AuctionContext
      ##
      # Abstract base class for insert new tuples on auctions table.
      # @abstract
      class CreateAuction < ROM::Commands::Create[:sql]
        relation :auctions
        register_as :create
        result :one

        use :timestamps
        timestamp :created_at, :updated_at
      end
    end
  end
end
