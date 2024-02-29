# frozen_string_literal: true

module AuctionFunCore
  module Events
    # Event class to register business events on system.
    # @see https://dry-rb.org/gems/dry-events/main/
    class App
      # @!parser include Dry::Events::Publisher[:app]
      include Dry::Events::Publisher[:app]

      register_event("auctions.created")
      register_event("auctions.started")
      register_event("auctions.finished")

      register_event("staffs.authentication")
      register_event("staffs.registration")

      register_event("users.authentication")
      register_event("users.registration")
      register_event("users.confirmation")
    end
  end
end
