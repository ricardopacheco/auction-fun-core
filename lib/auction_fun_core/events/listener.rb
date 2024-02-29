# frozen_string_literal: true

module AuctionFunCore
  module Events
    # Event class that can listen business events.
    # @see https://dry-rb.org/gems/dry-events/main/#event-listeners
    class Listener
      # Listener for to *auctions.created* event.
      # @param auction [ROM::Struct::Auction] the auction object
      def on_auctions_created(auction)
        logger("Create auction with: #{auction.to_h}")
      end

      # Listener for to *auctions.started* event.
      # @param auction [ROM::Struct::Auction] the auction object
      def on_auctions_started(auction)
        logger("Started auction with: #{auction.to_h}")
      end

      # Listener for to *auctions.finished* event.
      # @param auction [ROM::Struct::Auction] the auction object
      def on_auctions_finished(auction)
        logger("Finished auction: #{auction.to_h}")
      end

      # Listener for to *staffs.authentication* event.
      # @param attributes [Hash] Authentication attributes
      # @option staff_id [Integer] Staff ID
      # @option time [DateTime] Authentication time
      def on_staffs_authentication(attributes)
        logger("Staff #{attributes[:staff_id]} authenticated on: #{attributes[:time].iso8601}")
      end

      # Listener for to *staffs.registration* event.
      # @param user [ROM::Struct::Staff] the staff object
      def on_staffs_registration(staff)
        logger("New registered staff: #{staff.to_h}")
      end

      # Listener for to *users.registration* event.
      # @param user [ROM::Struct::User] the user object
      def on_users_registration(user)
        logger("New registered user: #{user.to_h}")
      end

      # Listener for to *users.authentication* event.
      # @param attributes [Hash] Authentication attributes
      # @option user_id [Integer] User ID
      # @option time [DateTime] Authentication time
      def on_users_authentication(attributes)
        logger("User #{attributes[:user_id]} authenticated on: #{attributes[:time].iso8601}")
      end

      # Listener for to *users.confirmation* event.
      # @param attributes [Hash] Confirmation attributes
      # @option user_id [Integer] User ID
      # @option time [DateTime] Authentication time
      def on_users_confirmation(attributes)
        logger("User #{attributes[:user_id]} confirmed at: #{attributes[:time].iso8601}")
      end

      private

      # Append message to system log.
      # @param message [String] the message
      def logger(message)
        Application[:logger].info(message)
      end
    end
  end
end
