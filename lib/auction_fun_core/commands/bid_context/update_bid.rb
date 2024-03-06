# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module BidContext
      ##
      # Abstract base class for updates all tuples in its bids table with new attributes
      # @abstract
      class UpdateBid < ROM::Commands::Update[:sql]
        relation :bids
        register_as :update

        use :timestamps
        timestamp :updated_at
      end
    end
  end
end
