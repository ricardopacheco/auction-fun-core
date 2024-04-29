# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        ##
        # This class is designed to validate the initiation of auctions. It ensures
        # the auction exists and is of a valid kind, and also manages specific rules for auctions
        # that require a stopwatch, such as penny auctions.
        #
        # @example Starting an auction
        #   contract = AuctionFunCore::Contracts::AuctionContext::Processor::StartContract.new
        #   attributes = { auction_id: 123, kind: "penny", stopwatch: 30 }
        #   result = contract.call(attributes)
        #   if result.success?
        #     puts "Auction started successfully."
        #   else
        #     puts "Failed to start auction: #{result.errors.to_h}"
        #   end
        #
        class StartContract < Contracts::ApplicationContract
          include AuctionFunCore::Business::Configuration

          # Repository initialized to retrieve auction data for validation.
          option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

          # Parameters specifying the required input types and fields.
          params do
            required(:auction_id).filled(:integer)
            required(:kind).value(included_in?: AUCTION_KINDS)
            optional(:stopwatch).filled(:integer)
          end

          # Validates the existence of the auction.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repo.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Validates the requirements for the stopwatch in penny auctions.
          rule(:stopwatch) do
            # Must be filled if auction kind is type penny.
            key.failure(I18n.t("contracts.errors.filled?")) if !key? && values[:kind] == "penny"

            # Must be an integer between 15 and 60.
            if key? && values[:kind] == "penny" && !value.between?(AUCTION_STOPWATCH_MIN_VALUE, AUCTION_STOPWATCH_MAX_VALUE)
              key.failure(
                I18n.t("contracts.errors.included_in?.arg.range",
                  list_left: AUCTION_STOPWATCH_MIN_VALUE, list_right: AUCTION_STOPWATCH_MAX_VALUE)
              )
            end
          end
        end
      end
    end
  end
end
