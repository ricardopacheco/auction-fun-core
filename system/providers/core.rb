# frozen_string_literal: true

# This file load requirements to main API.
AuctionFunCore::Application.register_provider(:core) do
  prepare do
    require 'dry/validation'
    require 'dry/monads/all'
    require 'dry/matcher/result_matcher'
    require 'dry/events'
  end

  start do
    target.start(:settings)
    target.start(:persistence)

    Dry::Schema.load_extensions(:hints)
    Dry::Schema.load_extensions(:info)
    Dry::Schema.load_extensions(:monads)
    Dry::Validation.load_extensions(:monads)
    Dry::Types.load_extensions(:monads)
  end
end
