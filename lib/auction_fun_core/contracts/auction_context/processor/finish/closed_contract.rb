# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        module Finish
          ##
          # This class is designed for validate the finishing closed auctions. It ensures that
          # the auction to be closed exists, is of the correct kind ('closed'), and is in the correct
          # status ('running') to be finalized.
          #
          # @example Validating a closed auction
          #   contract = AuctionFunCore::Contracts::AuctionContext::Processor::Finish::ClosedContract.new
          #   attributes = { auction_id: 123 }
          #   result = contract.call(attributes)
          #   if result.success?
          #     puts "Auction can be finished."
          #   else
          #     puts "Failed to finish auction: #{result.errors.to_h}"
          #   end
          #
          class ClosedContract < Contracts::ApplicationContract
            # Internationalization (i18n) scope for error messages.
            I18N_SCOPE = "contracts.errors.custom.auction_context.processor.finish"

            # Repository initialized to retrieve auction data for validation.
            option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

            # Parameters specifying the required input types and fields.
            params do
              required(:auction_id).filled(:integer)
            end

            # Validates the existence of the auction.
            rule(:auction_id) do |context:|
              context[:auction] ||= auction_repository.by_id(value)
              key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
            end

            # Validates the kind of the auction to ensure it is 'closed'.
            rule do |context:|
              next if context[:auction].present? && context[:auction].kind == "closed"

              key(:base).failure(I18n.t("invalid_kind", scope: I18N_SCOPE))
            end

            # Validates the status of the auction to ensure it is 'running'.
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
