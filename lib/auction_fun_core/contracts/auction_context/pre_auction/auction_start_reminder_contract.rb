# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PreAuction
        ##
        # Contract class for validate schedule reminder notification.
        #
        class AuctionStartReminderContract < Contracts::ApplicationContract
          I18N_SCOPE = "contracts.errors.custom.auction_context.pre_auction.auction_start_reminder"

          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

          params do
            required(:auction_id).filled(:integer)
          end

          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Validation to start.
          # Checks whether the auction has started or not.
          #
          rule do |context:|
            next if context[:auction].present? && context[:auction].not_started?

            key(:base).failure(I18n.t("auction_already_started", scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
