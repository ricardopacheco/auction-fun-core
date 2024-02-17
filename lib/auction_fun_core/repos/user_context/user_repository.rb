# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module UserContext
      # SQL repository for users.
      class UserRepository < ROM::Repository[:users]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all users in database.
        # @return [Array<ROM::Struct::User>, []]
        def all
          users.to_a
        end

        # Returns the total number of users in database.
        # @return [Integer]
        def count
          users.count
        end

        # Mount SQL conditions in query for search in database.
        # @param conditions [Hash] DSL Dataset
        # @return [AuctionFunCore::Relations::Users]
        def query(conditions)
          users.where(conditions)
        end

        # Search user in database by primary key.
        # @param id [Integer] User ID
        # @return [ROM::Struct::User, nil]
        def by_id(id)
          users.by_pk(id).one
        end

        # Search user in database by primary key.
        # @param id [Integer] User ID
        # @raise [ROM::TupleCountMismatchError] if not found on database
        # @return [ROM::Struct::Auction]
        def by_id!(id)
          users.by_pk(id).one!
        end

        # Search user in database by email of phone keys.
        # @param login [String] User email or phone
        # @return [ROM::Struct::User, nil]
        def by_login(login)
          users.where(Sequel[email: login] | Sequel[phone: login]).one
        end

        # Checks if it returns any user given one or more conditions.
        # @param conditions [Hash] DSL Dataset
        # @return [true] when some user is returned from the given condition.
        # @return [false] when no user is returned from the given condition.
        def exists?(conditions)
          users.exist?(conditions)
        end
      end
    end
  end
end
