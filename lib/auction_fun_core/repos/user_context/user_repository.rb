# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module UserContext
      # Repository for handling repository operations related to users.
      #
      # This repository provides methods to interact with user data in the database,
      # including creating, updating, deleting, and retrieving users.
      #
      # @example
      #   user_repo = AuctionFunCore::Repos::UserContext::UserRepository.new
      #
      #   # Retrieve all users
      #   all_users = user_repo.all
      #
      #   # Get the total number of users
      #   total_users = user_repo.count
      #
      #   # Find a user by its ID
      #   user = user_repo.by_id(123)
      #
      #   # Find a user by its ID and raise an error if not found
      #   user = user_repo.by_id!(123)
      #
      #   # Search for a user by email or phone
      #   user = user_repo.by_login('example@example.com')
      #   user = user_repo.by_login('1234567890')
      #
      #   # Search for a user by email confirmation token
      #   user = user_repo.by_email_confirmation_token('email_confirmation_token')
      #
      #   # Search for a user by phone confirmation token
      #   user = user_repo.by_phone_confirmation_token('phone_confirmation_token')
      #
      # @see AuctionFunCore::Entities::User Struct representing user data
      # @see https://rom-rb.org/learn/sql/3.3/queries/
      # @see https://api.rom-rb.org/rom-sql/ROM/SQL/Relation/Reading
      #
      class UserRepository < ROM::Repository[:users]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all users in database.
        # @return [Array<ROM::Struct::User>]
        def all
          users.to_a
        end

        # Returns the total number of users in database.
        # @return [Integer]
        def count
          users.count
        end

        # Constructs SQL conditions for querying users in the database.
        #
        # @param conditions [Hash] The conditions to be used in the query (DSL Dataset).
        # @return [AuctionFunCore::Relations::Users] The relation containing the users that match the given conditions.
        def query(conditions)
          users.where(conditions)
        end

        # Retrieves a user from the database by its primary key.
        #
        # @param id [Integer] The ID of the user to retrieve.
        # @return [ROM::Struct::User, nil] The retrieved user, or nil if not found.
        #
        def by_id(id)
          users.by_pk(id).one
        end

        # Retrieves a user from the database by its primary key, raising an error if not found.
        #
        # @param id [Integer] The ID of the user to retrieve.
        # @raise [ROM::TupleCountMismatchError] if the user is not found.
        # @return [ROM::Struct::User] The retrieved user.
        #
        def by_id!(id)
          users.by_pk(id).one!
        end

        # Searches for a user in the database by email or phone keys.
        #
        # @param login [String] The email or phone of the user.
        # @return [ROM::Struct::User, nil] The user found with the provided email or phone,
        #   or nil if not found.
        def by_login(login)
          users.where(Sequel[email: login] | Sequel[phone: login]).one
        end

        # Searches for a user in the database by email confirmation token.
        #
        # @param email_confirmation_token [String] The email confirmation token of the user.
        # @return [ROM::Struct::User, nil] The user found with the provided email confirmation token,
        #   or nil if not found.
        def by_email_confirmation_token(email_confirmation_token)
          users.where(Sequel[email_confirmation_token: email_confirmation_token]).one
        end

        # Searches for a user in the database by phone confirmation token.
        #
        # @param phone_confirmation_token [String] The phone confirmation token of the user.
        # @return [ROM::Struct::User, nil] The user found with the provided phone confirmation token,
        #   or nil if not found.
        def by_phone_confirmation_token(phone_confirmation_token)
          users.where(Sequel[phone_confirmation_token: phone_confirmation_token]).one
        end

        # Checks if a user exists based on the provided conditions.
        #
        # @param conditions [Hash] The conditions to check (DSL Dataset).
        # @return [Boolean] true if a user exists that matches the conditions, otherwise false.
        def exists?(conditions)
          users.exist?(conditions)
        end
      end
    end
  end
end
