# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        ##
        # Contract class for finish auctions.
        #
        class FinishContract < Contracts::ApplicationContract
          option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

          params do
            required(:auction_id).filled(:integer)
          end

          # Validation for auction.
          # Validates if the auction exists in the database.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repo.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end
        end
      end
    end
  end
end
