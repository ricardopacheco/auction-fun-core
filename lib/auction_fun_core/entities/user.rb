# frozen_string_literal: true

module AuctionFunCore
  module Entities
    ##
    # Defines the User class as Entity. It appears to be a simple data structure
    # class representing user-related information.
    class User < ROM::Struct
      ##
      # Checks if the user is active.
      #
      # @return [Boolean] True if the user is active, otherwise false.
      def active?
        active
      end

      ##
      # Checks if the user is inactive.
      #
      # @return [Boolean] True if the user is inactive, otherwise false.
      def inactive?
        !active
      end

      ##
      # Checks if the user has been confirmed.
      #
      # @return [Boolean] True if the user is confirmed, otherwise false.
      def confirmed?
        confirmed_at.present?
      end

      ##
      # Checks if the user's email has been confirmed.
      #
      # @return [Boolean] True if the email is confirmed, otherwise false.
      def email_confirmed?
        email_confirmation_at.present?
      end

      ##
      # Checks if the user's phone has been confirmed.
      #
      # @return [Boolean] True if the phone is confirmed, otherwise false.
      def phone_confirmed?
        phone_confirmation_at.present?
      end

      ##
      # Returns user information excluding password digest.
      #
      # @return [Hash] User information.
      def info
        attributes.except(:password_digest)
      end

      ##
      # Returns the user's balance as a Money object.
      #
      # @return [Money] User's balance.
      def balance
        Money.new(balance_cents, balance_currency)
      end
    end
  end
end
