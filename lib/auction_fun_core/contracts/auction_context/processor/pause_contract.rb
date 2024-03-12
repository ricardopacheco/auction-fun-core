# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module Processor
        ##
        # Contract class for pause auction.
        #
        class PauseContract < Contracts::ApplicationContract
          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }

          params do
            required(:auction_id).filled(:integer)
          end

          # Validation for auction.
          # Validates if the auction exists in the database and check if  only auctions
          # with a "running" status can be paused.
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
