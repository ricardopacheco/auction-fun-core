# frozen_string_literal: true

ENV["APP_ENV"] ||= "development"

require "bundler"
Bundler.setup(:default, ENV.fetch("APP_ENV", nil))

unless defined?(Dotenv)
  require "dotenv"
  Dotenv.load(".env.#{ENV.fetch("APP_ENV", nil)}")
  Dotenv.require_keys(
    "DATABASE_URL", "REDIS_URL", "DEFAULT_EMAIL_SYSTEM", "SMTP_ADDRESS", "SMTP_PORT"
  )
end
