# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module StaffContext
      # SQL repository for staffs.
      class StaffRepository < ROM::Repository[:staffs]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all staffs in database.
        # @return [Array<ROM::Struct::Staff>, []]
        def all
          staffs.to_a
        end

        # Returns the total number of staffs in database.
        # @return [Integer]
        def count
          staffs.count
        end

        # Mount SQL conditions in query for search in database.
        # @param conditions [Hash] DSL Dataset
        # @return [AuctionFunCore::Relations::Staffs]
        def query(conditions)
          staffs.where(conditions)
        end

        # Search staff in database by primary key.
        # @param id [Integer] Staff ID
        # @return [ROM::Struct::Staff, nil]
        def by_id(id)
          staffs.by_pk(id).one
        end

        # Search staffs in database by primary key.
        # @param id [Integer] Staff ID
        # @raise [ROM::TupleCountMismatchError] if not found on database
        # @return [ROM::Struct::Auction]
        def by_id!(id)
          staffs.by_pk(id).one!
        end

        # Checks if it returns any staff given one or more conditions.
        # @param conditions [Hash] DSL Dataset
        # @return [true] when some staff is returned from the given condition.
        # @return [false] when no staff is returned from the given condition.
        def exists?(conditions)
          staffs.exist?(conditions)
        end
      end
    end
  end
end
