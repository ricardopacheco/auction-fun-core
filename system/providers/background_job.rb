# frozen_string_literal: true

AuctionFunCore::Application.register_provider(:background_job) do
  prepare do
    require "sidekiq"
    require "sidekiq-unique-jobs"
  end

  start do
    Sidekiq.configure_server do |config|
      # Set up Sidekiq server configuration
      config.redis = {url: target[:settings].redis_url}
      config.logger = target[:settings].logger
      config.average_scheduled_poll_interval = 3

      # Configure client middleware for uniqueness
      config.client_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Client
      end

      # Configure server middleware for uniqueness
      config.server_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Server
      end

      # Configure Sidekiq Unique Jobs for the server
      SidekiqUniqueJobs::Server.configure(config)
    end

    # Configure client middleware for uniqueness
    Sidekiq.configure_client do |config|
      # Set up Sidekiq client configuration
      config.redis = {url: target[:settings].redis_url}

      config.client_middleware do |chain|
        chain.add SidekiqUniqueJobs::Middleware::Client
      end
    end
  end
end
