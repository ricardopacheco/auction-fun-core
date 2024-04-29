# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PreAuction
        # The AuctionStartReminderContract class validates the scheduled reminder for the auction start.
        # It checks if the auction associated with the provided auction ID has not started yet and validates accordingly.
        #
        # @example Validating auction reminder
        #   contract = AuctionFunCore::Contracts::AuctionContext::PreAuction::AuctionStartReminderContract.new
        #   attributes = { auction_id: 123 }
        #   result = contract.call(attributes)
        #   if result.success?
        #     puts "Reminder setup is valid."
        #   else
        #     puts "Failed to validate reminder: #{result.errors.to_h}"
        #   end
        #
        class AuctionStartReminderContract < Contracts::ApplicationContract
          # Scope for internationalization (i18n) entries specific to errors in this contract.
          I18N_SCOPE = "contracts.errors.custom.auction_context.pre_auction.auction_start_reminder"

          # Default repository initialization to retrieve auction data.
          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

          # Defines the necessary parameters and their types.
          params do
            required(:auction_id).filled(:integer)
          end

          # Validation rule to ensure the referenced auction exists.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Additional validation to confirm the auction has not started yet.
          rule do |context:|
            next if context[:auction].present? && context[:auction].not_started?

            key(:base).failure(I18n.t("auction_already_started", scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
