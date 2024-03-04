# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        ##
        # Contract class for start auctions.
        #
        class StartContract < Contracts::ApplicationContract
          STOPWATCH_MIN_VALUE = 15
          STOPWATCH_MAX_VALUE = 60
          KINDS = Relations::Auctions::KINDS.values
          option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

          params do
            required(:auction_id).filled(:integer)
            required(:kind).value(included_in?: KINDS)
            optional(:stopwatch).filled(:integer)
          end

          # Validation for auction.
          # Validates if the auction exists in the database.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repo.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Validation for stopwatch.
          #
          rule(:stopwatch) do
            # Must be filled if auction kind is type penny.
            key.failure(I18n.t("contracts.errors.filled?")) if !key? && values[:kind] == "penny"

            # Must be an integer between 15 and 60.
            if key? && values[:kind] == "penny" && !value.between?(STOPWATCH_MIN_VALUE, STOPWATCH_MAX_VALUE)
              key.failure(
                I18n.t("contracts.errors.included_in?.arg.range",
                  list_left: STOPWATCH_MIN_VALUE, list_right: STOPWATCH_MAX_VALUE)
              )
            end
          end
        end
      end
    end
  end
end
