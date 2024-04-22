# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PostAuction
        ##
        # Contract class for validate winner auction.
        #
        class WinnerContract < Contracts::ApplicationContract
          I18N_SCOPE = "contracts.errors.custom.auction_context.post_auction.winner"

          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
          option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

          params do
            required(:auction_id).filled(:integer)
            required(:winner_id).filled(:integer)
          end

          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          rule(:winner_id) do |context:|
            context[:winner] ||= user_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:winner]
          end

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
