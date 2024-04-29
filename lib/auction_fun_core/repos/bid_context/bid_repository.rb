# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module BidContext
      # Repository for handling repository operations related to bids.
      #
      # This repository provides methods to interact with bid data in the database,
      # including creating, updating, deleting, and retrieving bids.
      #
      # @example
      #   bid_repo = AuctionFunCore::Repos::BidContext::BidRepository.new
      #
      #   # Get the total number of bids
      #   total_bids = bid_repo.count
      #
      #   # Checks if a bid exists based on the provided conditions.
      #   bid_repo.exists?(id: 123)
      #
      # @see AuctionFunCore::Entities::Bid Struct representing bid data
      # @see https://rom-rb.org/learn/sql/3.3/queries/
      # @see https://api.rom-rb.org/rom-sql/ROM/SQL/Relation/Reading
      #
      class BidRepository < ROM::Repository[:bids]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns the total number of bids in the database.
        #
        # @return [Integer] Total number of bids.
        #
        def count
          bids.count
        end

        # Checks if a bid exists based on the provided conditions.
        #
        # @param conditions [Hash] The conditions to check (DSL Dataset).
        # @return [Boolean] true if a bid exists that matches the conditions, otherwise false.
        #
        def exists?(conditions)
          bids.exist?(conditions)
        end
      end
    end
  end
end
