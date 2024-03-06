# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module BidContext
      ##
      # Abstract base class for insert new tuples on bids table.
      # @abstract
      class CreateBid < ROM::Commands::Create[:sql]
        relation :bids
        register_as :create
        result :one

        use :timestamps
        timestamp :created_at, :updated_at
      end
    end
  end
end
