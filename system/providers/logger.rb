# frozen_string_literal: true

AuctionFunCore::Application.register_provider(:logger) do
  prepare do
    require "logger"
  end

  start do
    register(:logger, AuctionFunCore::Application[:settings].logger)
  end
end
