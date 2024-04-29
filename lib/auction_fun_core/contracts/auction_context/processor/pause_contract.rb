# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        ##
        # This class is designed to validate pausing an auction. It ensures
        # that the auction exists in the database and checks that only auctions with
        # a "running" status can be paused.
        #
        # @example Pausing an auction
        #   contract = AuctionFunCore::Contracts::AuctionContext::Processor::PauseContract.new
        #   attributes = { auction_id: 123 }
        #   result = contract.call(attributes)
        #   if result.success?
        #     puts "Auction paused successfully."
        #   else
        #     puts "Failed to pause auction: #{result.errors.to_h}"
        #   end
        #
        class PauseContract < Contracts::ApplicationContract
          # Repository initialized to retrieve auction data for validation.
          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

          # Parameters specifying the required input types and fields.
          params do
            required(:auction_id).filled(:integer)
          end

          # Validates the existence of the auction and its status.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]

            unless %w[running].include?(context[:auction].status)
              key.failure(
                I18n.t("contracts.errors.custom.bids.invalid_status", status: context[:auction].status)
              )
            end
          end
        end
      end
    end
  end
end
