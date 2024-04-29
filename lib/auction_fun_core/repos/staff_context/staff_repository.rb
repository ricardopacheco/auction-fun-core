# frozen_string_literal: true

module AuctionFunCore
  module Repos
    module StaffContext
      # Repository for handling repository operations related to staffs.
      #
      # This repository provides methods to interact with staff data in the database,
      # including creating, updating, deleting, and retrieving staffs.
      #
      # @example
      #   staff_repo = AuctionFunCore::Repos::StaffContext::StaffRepository.new
      #
      #   # Retrieve all staffs
      #   all_staffs = staff_repo.all
      #
      #   # Get the total number of staffs
      #   total_staffs = staff_repo.count
      #
      #   # Search staffs based on certain conditions
      #   conditions = {name: 'Staff'}
      #   search = staff_repo.query(conditions)
      #
      #   # Find an staff by its ID
      #   staff = staff_repo.by_id(123)
      #
      #   # Find an staff by its ID and raise an error if not found
      #   staff = staff_repo.by_id!(123)
      #
      #   # Search for a staff by email or phone
      #   staff_by_login = staff_repo.by_login('example@example.com')
      #
      #   # Check if a staff exists based on certain conditions
      #   conditions = { name: 'John Doe' }
      #   staff_exists = staff_repo.exists?(conditions)
      #
      # @see AuctionFunCore::Entities::Staff Struct representing staff data
      # @see https://rom-rb.org/learn/sql/3.3/queries/
      # @see https://api.rom-rb.org/rom-sql/ROM/SQL/Relation/Reading
      #
      class StaffRepository < ROM::Repository[:staffs]
        include Import["container"]

        struct_namespace Entities
        commands :create, update: :by_pk, delete: :by_pk

        # Returns all staffs in database.
        # @return [Array<ROM::Struct::Staff>]
        def all
          staffs.to_a
        end

        # Returns the total number of staffs in the database.
        #
        # @return [Integer] Total number of staffs.
        def count
          staffs.count
        end

        # Constructs SQL conditions for querying staffs in the database.
        #
        # @param conditions [Hash] The conditions to be used in the query (DSL Dataset).
        # @return [AuctionFunCore::Relations::Staff] The relation containing the staffs that match the given conditions.
        def query(conditions)
          staffs.where(conditions)
        end

        # Retrieves an staff from the database by its primary key.
        #
        # @param id [Integer] The ID of the staff to retrieve.
        # @return [ROM::Struct::Staff, nil] The retrieved staff, or nil if not found.
        #
        def by_id(id)
          staffs.by_pk(id).one
        end

        # Retrieves an staff from the database by its primary key, raising an error if not found.
        #
        # @param id [Integer] The ID of the staff to retrieve.
        # @raise [ROM::TupleCountMismatchError] if the staff is not found.
        # @return [ROM::Struct::Staff] The retrieved staff.
        #
        def by_id!(id)
          staffs.by_pk(id).one!
        end

        # Searches for a staff in the database by email or phone keys.
        #
        # @param login [String] The email or phone of the staff.
        # @return [ROM::Struct::Staff, nil] The staff found with the provided email or phone,
        #   or nil if not found.
        def by_login(login)
          staffs.where(Sequel[email: login] | Sequel[phone: login]).one
        end

        # Checks if a bid exists based on the provided conditions.
        #
        # @param conditions [Hash] The conditions to check (DSL Dataset).
        # @return [Boolean] true if a staff exists that matches the conditions, otherwise false.
        def exists?(conditions)
          staffs.exist?(conditions)
        end
      end
    end
  end
end
