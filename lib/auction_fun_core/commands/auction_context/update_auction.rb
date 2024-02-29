# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module AuctionContext
      ##
      # Abstract base class for updates all tuples in its auctions table with new attributes
      # @abstract
      class UpdateAuction < ROM::Commands::Update[:sql]
        relation :auctions
        register_as :update

        use :timestamps
        timestamp :updated_at
      end
    end
  end
end
