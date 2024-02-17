# frozen_string_literal: true

AuctionFunCore::Application.register_provider(:events) do
  start do
    register(:event, AuctionFunCore::Events::App.new)
    register(:listener, AuctionFunCore::Events::Listener.new)
    register(:subscription, event.subscribe(listener))
  end

  stop do
    container["subscription"].unsubscribe(listener)
  end
end
