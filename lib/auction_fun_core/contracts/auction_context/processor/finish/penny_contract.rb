# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        module Finish
          ##
          # Contract class for finishing penny auctions.
          #
          class PennyContract < Contracts::ApplicationContract
            I18N_SCOPE = "contracts.errors.custom.auction_context.processor.finish"

            option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

            params do
              required(:auction_id).filled(:integer)
            end

            # Validation for auction.
            # Validates if the auction exists in the database.
            rule(:auction_id) do |context:|
              context[:auction] ||= auction_repository.by_id(value)

              key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
            end

            # Validation for kind.
            #
            rule do |context:|
              next if context[:auction].present? && context[:auction].kind == "penny"

              key(:base).failure(I18n.t("invalid_kind", scope: I18N_SCOPE))
            end

            # Validation for status.
            #
            rule do |context:|
              next if context[:auction].present? && context[:auction].status == "running"

              key(:base).failure(I18n.t("invalid_status", scope: I18N_SCOPE))
            end
          end
        end
      end
    end
  end
end
