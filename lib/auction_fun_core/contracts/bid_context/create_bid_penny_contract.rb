# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # Contract class to create new bids.
      class CreateBidPennyContract < Contracts::ApplicationContract
        option :user_repo, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

        # @param [Hash] opts Sets an allowed list of parameters, as well as some initial validations.
        params do
          required(:auction_id).filled(:integer)
          required(:user_id).filled(:integer)

          # Keys with a blank value are discarded.
          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Validation for auction.
        # validate whether the given auction is valid at the database level.
        # validate if the auction is open to receive bids
        rule(:auction_id) do |context:|
          context[:auction] ||= auction_repo.by_id(value)

          if context[:auction]
            if context[:auction].kind != "penny"
              key.failure(I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "penny"))
            end

            unless %w[scheduled running].include?(context[:auction].status)
              key.failure(
                I18n.t("contracts.errors.custom.bids.invalid_status", status: context[:auction].status)
              )
            end
          else
            key.failure(I18n.t("contracts.errors.custom.not_found"))
          end
        end

        # Validation for user.
        # Validate whether the given user is valid at the database level.
        # Validates if user has enough balance to bid.
        rule(:user_id) do |context:|
          context[:user] ||= user_repo.by_id(value)

          if context[:user]
            unless rule_error?(:auction_id)
              penny_auction_check_user_has_balance?(
                key, context[:auction].initial_bid_cents, context[:user].balance_cents
              )
            end
          else
            key.failure(I18n.t("contracts.errors.custom.not_found"))
          end
        end

        private

        # Checks if user has enough balance to bid.
        def penny_auction_check_user_has_balance?(key, auction_bid_cents, balance_cents)
          key.failure(I18n.t("contracts.errors.custom.bids.insufficient_balance")) if balance_cents < auction_bid_cents
        end
      end
    end
  end
end
