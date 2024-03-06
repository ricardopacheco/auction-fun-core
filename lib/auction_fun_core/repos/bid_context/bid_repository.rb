# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module BidContext
      # SQL repository for bids.
      class BidRepository < ROM::Repository[:bids]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns the total number of bids in database.
        # @return [Integer]
        def count
          bids.count
        end

        # @param conditions [Hash] DSL Dataset
        # @return [Boolean]
        def exists?(conditions)
          bids.exist?(conditions)
        end
      end
    end
  end
end
