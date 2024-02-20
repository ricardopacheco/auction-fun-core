# frozen_string_literal: true

module AuctionFunCore
  module Events
    # Event class that can listen business events.
    # @see https://dry-rb.org/gems/dry-events/main/#event-listeners
    class Listener
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

      private

      # Append message to system log.
      # @param message [String] the message
      def logger(message)
        Application[:logger].info(message)
      end
    end
  end
end
