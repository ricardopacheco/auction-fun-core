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
        address: target[:settings].smtp_address,
        port: target[:settings].smtp_port
      }
      config.default_from = target[:settings].default_email_system
      config.logger = nil
      config.log_body = false
    end
  end
end
