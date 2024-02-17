# frozen_string_literal: true

require_relative "boot"

require "bcrypt"
require "zeitwerk"
require "i18n"
require "dry/system"
require "dry/system/loader/autoloading"
require "dry/auto_inject"
require "dry/types"

module AuctionFunCore
  # Main class (Add doc)
  class Application < Dry::System::Container
    I18n.available_locales = %w[en-US pt-BR]
    I18n.default_locale = "pt-BR"
    use :env, inferrer: -> { ENV.fetch("APP_ENV", "development").to_sym }
    use :zeitwerk, run_setup: true, eager_load: true

    configure do |config|
      config.root = File.expand_path("..", __dir__)

      config.component_dirs.add "lib" do |dir|
        dir.auto_register = true
        dir.loader = Dry::System::Loader::Autoloading
        dir.add_to_load_path = true
        dir.namespaces.add "auction_fun_core", key: nil
      end
    end
  end

  Import = Dry::AutoInject(Application)
end
