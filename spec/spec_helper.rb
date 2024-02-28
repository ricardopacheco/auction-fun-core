# frozen_string_literal: true

ENV["APP_ENV"] = "test"

if ENV["CI"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec"
    add_group "Commands", "lib/auction_fun_core/commands"
    add_group "Contracts", "lib/auction_fun_core/contracts"
    add_group "Entities", "lib/auction_fun_core/entities"
    add_group "Operations", "lib/auction_fun_core/operations"
    add_group "Relations", "lib/auction_fun_core/relations"
    add_group "Repositories", "lib/auction_fun_core/repos"
    add_group "Services", "lib/auction_fun_core/services"
    add_group "Workers", "lib/auction_fun_core/workers"
    add_group "System", "system"
    add_group "Config", "config"
  end
end

require_relative "../config/application"
require "pry"
require "dotenv"
require "rom-factory"
require "database_cleaner/sequel"
require "sidekiq/testing"

AuctionFunCore::Application.start(:core)

Factory = ROM::Factory.configure do |config|
  config.rom = AuctionFunCore::Application[:container]
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.add_setting :rom
  config.rom = Factory.rom

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    DatabaseCleaner.clean
    Sidekiq::Worker.clear_all
  end

  config.after(:suite) do
    AuctionFunCore::Application.stop(:core)
  end
end

DatabaseCleaner.strategy = :truncation
