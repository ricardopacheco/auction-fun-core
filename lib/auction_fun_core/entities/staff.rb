# frozen_string_literal: true

module AuctionFunCore
  module Entities
    ##
    # Defines the Staff class as Entity. It appears to be a simple data structure
    # class representing staff-related information.
    class Staff < ROM::Struct
      ##
      # Checks if the staff is active.
      #
      # @return [Boolean] True if the staff is active, otherwise false.
      def active?
        active
      end

      ##
      # Checks if the staff is inactive.
      #
      # @return [Boolean] True if the staff is inactive, otherwise false.
      def inactive?
        !active
      end

      ##
      # Returns staff information excluding password digest.
      #
      # @return [Hash] Staff information.
      def info
        attributes.except(:password_digest)
      end
    end
  end
end
