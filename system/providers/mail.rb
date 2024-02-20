# frozen_string_literal: true

# This file uses the rom gem to define a database configuration container
# and registers it with our application under the container key.
AuctionFunCore::Application.register_provider(:mail) do
  prepare do
    require "action_mailer"
    require "pry"
  end

  start do
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.default_options = {from: "from@example.com", host: "http://localhost:3000"}
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.smtp_settings = {
      address: "localhost",
      port: 1025
    }
  end
end
