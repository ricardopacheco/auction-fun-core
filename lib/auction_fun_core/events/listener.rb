# frozen_string_literal: true

module AuctionFunCore
  module Events
    # Event class that can listen business events.
    # @see https://dry-rb.org/gems/dry-events/main/#event-listeners
    class Listener
      # Listener for to *users.registration* event.
      # @param event [ROM::Struct::User] the user object
      def on_users_registration(user)
        logger("New registered user: #{user.to_h}")
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
