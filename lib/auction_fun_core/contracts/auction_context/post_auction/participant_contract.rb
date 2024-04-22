# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PostAuction
        ##
        # Contract class for validate participation auction.
        #
        class ParticipantContract < Contracts::ApplicationContract
          I18N_SCOPE = "contracts.errors.custom.auction_context.post_auction.participation"

          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
          option :user_repository, default: proc { Repos::UserContext::UserRepository.new }
          option :bid_repository, default: proc { Repos::BidContext::BidRepository.new }

          params do
            required(:auction_id).filled(:integer)
            required(:participant_id).filled(:integer)
          end

          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          rule(:participant_id) do |context:|
            context[:participant] ||= user_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:participant]
          end

          rule(:auction_id, :participant_id) do |context:|
            next if (rule_error?(:auction_id) || schema_error?(:auction_id)) || (rule_error?(:winner_id) || schema_error?(:winner_id))
            next if bid_repository.exists?(auction_id: values[:auction_id], user_id: values[:participant_id])

            key(:participant_id).failure(I18n.t("none", scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
