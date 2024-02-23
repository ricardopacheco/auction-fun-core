# frozen_string_literal: true

# This file load requirements to main API.
AuctionFunCore::Application.register_provider(:core) do
  prepare do
    require "dry/validation"
    require "dry/monads/all"
    require "dry/matcher/result_matcher"
    require "active_support"
    require "active_support/core_ext/object/blank"
    require "active_support/time"
    require "dry/events"

    Dry::Schema.load_extensions(:hints)
    Dry::Schema.load_extensions(:info)
    Dry::Schema.load_extensions(:monads)
    Dry::Validation.load_extensions(:monads)
    Dry::Types.load_extensions(:monads)
  end

  start do
    target.start(:settings)
    target.start(:events)
    target.start(:logger)
    target.start(:persistence)
    target.start(:mail)
  end

  stop do
    target.stop(:settings)
    target.stop(:events)
    target.stop(:logger)
    target.stop(:persistence)
  end
end
