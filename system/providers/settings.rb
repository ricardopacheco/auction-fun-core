# frozen_string_literal: true

require "dry/system/provider_sources"

# This file uses the rom gem to define a database configuration container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:settings, from: :dry_system) do
  before :prepare do
    require "money"
  end

  settings do
    setting :database_url, constructor: Dry::Types["string"].constrained(filled: true)
    setting :logger, default: Logger.new($stdout)
    setting :logger_level, default: :info, constructor: Dry::Types["symbol"]
      .constructor { |value| value.to_s.downcase.to_sym }
      .enum(:trace, :unknown, :error, :fatal, :warn, :info, :debug)
  end
end