# frozen_string_literal: true

module AuctionFunCore
  module Events
    # Event class to register business events on system.
    # @see https://dry-rb.org/gems/dry-events/main/
    class App
      # @!parser include Dry::Events::Publisher[:app]
      include Dry::Events::Publisher[:app]

      register_event("users.registration")
    end
  end
end
