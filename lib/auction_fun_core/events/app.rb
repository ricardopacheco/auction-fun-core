# frozen_string_literal: true

module AuctionFunCore
  module Events
    ##
    # Represents the main application class for registering business events in the system.
    #
    # This class includes Dry::Events::Publisher[:app] to enable event publishing functionality.
    # @see https://dry-rb.org/gems/dry-events/main/
    class App
      include Dry::Events::Publisher[:app]

      # Registers events related to auctions.
      register_event("auctions.created")
      register_event("auctions.started")
      register_event("auctions.finished")
      register_event("auctions.paused")
      register_event("auctions.unpaused")

      # Registers events related to bids.
      register_event("bids.created")

      # Registers events related to staffs.
      register_event("staffs.authentication")
      register_event("staffs.registration")

      # Registers events related to users.
      register_event("users.authentication")
      register_event("users.registration")
      register_event("users.confirmation")
    end
  end
end
