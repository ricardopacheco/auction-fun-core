# frozen_string_literal: true

AuctionFunCore::Application.register_provider(:background_job) do
  prepare do
    require "sidekiq"
    require "sidekiq-unique-jobs"
  end

  start do
    Sidekiq.configure_server do |config|
      config.redis = {url: target[:settings].redis_url}
      config.logger = target[:settings].logger
      config.average_scheduled_poll_interval = 3

      config.client_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Client
      end

      config.server_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Server
      end

      SidekiqUniqueJobs::Server.configure(config)
    end

    Sidekiq.configure_client do |config|
      config.redis = {url: target[:settings].redis_url}

      config.client_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Client
      end
    end
  end
end
