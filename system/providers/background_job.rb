# frozen_string_literal: true

AuctionFunCore::Application.register_provider(:background_job) do
  prepare do
    require "sidekiq"
  end

  start do
    Sidekiq.configure_server do |config|
      config.logger = target[:settings].logger
      config.average_scheduled_poll_interval = 3
      config.redis = {url: target[:settings].redis_url}
    end
  end
end
