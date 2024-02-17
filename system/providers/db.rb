# frozen_string_literal: true

# This file uses the rom gem to define a database configuration container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:db) do
  prepare do
    require "rom"
    require "rom-sql"
  end

  start do
    connection = Sequel.connect(
      AuctionFunCore::Application[:settings].database_url,
      extensions: %i[pg_array pg_json pg_enum]
    )
    migrator = ROM::SQL::Migration::Migrator.new(
      connection, path: Pathname.new(AuctionFunCore::Application.root.join("db/migrate"))
    )
    register(:db_connection, connection)
    register(:db_config, ROM::Configuration.new(:sql, connection, migrator: migrator))
  end

  stop do
    container["db_connection"].disconnect
  end
end
