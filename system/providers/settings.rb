# frozen_string_literal: true

require "dry/system/provider_sources"

# This file uses the rom gem to define a database configuration container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:settings, from: :dry_system) do
  before :prepare do
    require "money"
  end

  settings do
    setting :logger, default: Logger.new($stdout)
    setting :database_url, default: ENV.fetch("DATABASE_URL"),
      constructor: Dry::Types["string"].constrained(filled: true)
    setting :redis_url, default: ENV.fetch("REDIS_URL"),
      constructor: Dry::Types["string"].constrained(filled: true)
    setting :logger_level, default: :info, constructor: Dry::Types["symbol"]
      .constructor { |value| value.to_s.downcase.to_sym }
      .enum(:trace, :unknown, :error, :fatal, :warn, :info, :debug)
    setting :default_email_system, default: ENV.fetch("DEFAULT_EMAIL_SYSTEM"),
      constructor: Dry::Types["string"].constrained(filled: true)
    setting :smtp_address, default: ENV.fetch("SMTP_ADDRESS"),
      constructor: Dry::Types["string"].constrained(filled: true)
    setting :smtp_port, default: ENV.fetch("SMTP_PORT"),
      constructor: Dry::Types["string"].constrained(filled: true)
  end
end
