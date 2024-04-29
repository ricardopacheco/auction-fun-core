# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PostAuction
        ##
        # This class validates the identification of the winning bidder
        # in an auction context. It ensures that both the auction and the winner exist
        # and are correctly associated within the system.
        #
        # @example Using this class to validate a winner
        #   contract = AuctionFunCore::Contracts::AuctionContext::PostAuction::WinnerContract.new
        #   attributes = { auction_id: 1, winner_id: 102 }
        #   validation_result = contract.call(attributes)
        #   if validation_result.success?
        #     puts "Winner validation passed"
        #   else
        #     puts "Winner validation failed: #{validation_result.errors.to_h}"
        #   end
        #
        class WinnerContract < Contracts::ApplicationContract
          # Internationalization (i18n) scope for error messages related to winner validation.
          I18N_SCOPE = "contracts.errors.custom.auction_context.post_auction.winner"

          # Repositories initialized by default to handle data retrieval for validation.
          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
          option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

          # Parameters defining the expected input types and required fields.
          params do
            required(:auction_id).filled(:integer)
            required(:winner_id).filled(:integer)
          end

          # Validation rule to ensure the auction exists.
          # @param context [Hash] Optional context hash to store data and state during validation.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Validation rule to ensure the winner exists.
          # @param context [Hash] Optional context hash to store data and state during validation.
          rule(:winner_id) do |context:|
            context[:winner] ||= user_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:winner]
          end

          # Combined rule to ensure that the declared winner is the actual winner recorded in the auction.
          # @param context [Hash] Context containing the auction and winner objects.
          rule(:auction_id, :winner_id) do |context:|
            next if (rule_error?(:auction_id) || schema_error?(:auction_id)) || (rule_error?(:winner_id) || schema_error?(:winner_id))
            next if context[:auction].winner_id == values[:winner_id]

            key(:winner_id).failure(I18n.t("wrong", scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
