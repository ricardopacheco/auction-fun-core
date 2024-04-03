# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module AuctionContext
      # SQL repository for auctions.
      class AuctionRepository < ROM::Repository[:auctions]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all auctions in the database.
        # @return [Array<ROM::Struct::Auction>, []]
        def all
          auctions.to_a
        end

        # Returns the total number of auctions in database.
        # @return [Integer]
        def count
          auctions.count
        end

        # Search auction in database by primary key.
        # @param id [Integer] Auction ID
        # @return [ROM::Struct::Auction, nil]
        def by_id(id)
          auctions.by_pk(id).one
        end

        # Search auction in database by primary key.
        # @param id [Integer] Auction ID
        # @raise [ROM::TupleCountMismatchError] if not found on database
        # @return [ROM::Struct::Auction]
        def by_id!(id)
          auctions.by_pk(id).one!
        end
      end
    end
  end
end
