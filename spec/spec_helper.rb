# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

if ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec'
    add_group 'System', 'system'
    add_group 'Config', 'config'
  end
end

require_relative '../config/application'
require 'pry'
require 'dotenv'
require 'rom-factory'
require 'database_cleaner/sequel'

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
end
