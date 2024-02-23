# frozen_string_literal: true

# This file uses the rom gem to define a database configuration container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:mail) do
  prepare do
    require "idlemailer"
  end

  start do
    IdleMailer.config do |config|
      config.templates = Pathname.new(AuctionFunCore::Application.root).join("lib", "auction_fun_core", "services", "mail", "templates")
      config.cache_templates = true
      config.layout = "layout"
      config.delivery_method = :smtp
      config.delivery_options = {
        address: "localhost",
        port: 1025
      }
      config.default_from = "system@auctionfun.com"
      config.logger = nil
      config.log_body = false
    end
  end
end
