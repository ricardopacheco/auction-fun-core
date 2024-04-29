# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module AuctionContext
      # Repository for handling repository operations related to auctions.
      #
      # This repository provides methods to interact with auction data in the database,
      # including creating, updating, deleting, and retrieving auctions.
      #
      # @example
      #   auction_repo = AuctionFunCore::Repos::AuctionContext::AuctionRepository.new
      #
      #   # Retrieve all auctions
      #   all_auctions = auction_repo.all
      #
      #   # Get the total number of auctions
      #   total_auctions = auction_repo.count
      #
      #   # Find an auction by its ID
      #   auction = auction_repo.by_id(123)
      #
      #   # Find an auction by its ID and raise an error if not found
      #   auction = auction_repo.by_id!(123)
      #
      # @see AuctionFunCore::Entities::Auction Struct representing auction data
      # @see https://rom-rb.org/learn/sql/3.3/queries/
      # @see https://api.rom-rb.org/rom-sql/ROM/SQL/Relation/Reading
      #
      class AuctionRepository < ROM::Repository[:auctions]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all auctions in the database.
        # @return [Array<ROM::Struct::Auction>]
        def all
          auctions.to_a
        end

        # Returns the total number of auctions in the database.
        #
        # @return [Integer] Total number of auctions.
        #
        def count
          auctions.count
        end

        # Retrieves an auction from the database by its primary key.
        #
        # @param id [Integer] The ID of the auction to retrieve.
        # @return [ROM::Struct::Auction, nil] The retrieved auction, or nil if not found.
        #
        def by_id(id)
          auctions.by_pk(id).one
        end

        # Retrieves an auction from the database by its primary key, raising an error if not found.
        #
        # @param id [Integer] The ID of the auction to retrieve.
        # @raise [ROM::TupleCountMismatchError] if the auction is not found.
        # @return [ROM::Struct::Auction] The retrieved auction.
        #
        def by_id!(id)
          auctions.by_pk(id).one!
        end
      end
    end
  end
end
