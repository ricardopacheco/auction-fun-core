# frozen_string_literal: true

# This file uses the rom gem to define a database persistence container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:persistence) do
  prepare do
    require "rom"
    require "rom-sql"
  end

  start do
    configuration ||= ROM::Configuration.new(
      :sql, AuctionFunCore::Application[:settings].database_url, extensions: %i[pg_array pg_json pg_enum]
    )
    configuration.auto_registration("#{target.root}/lib/auction_fun_core")
    register(:container, ROM.container(configuration))
  end
end
