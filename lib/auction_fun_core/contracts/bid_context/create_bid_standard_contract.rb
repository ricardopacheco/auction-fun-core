# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # Contract class to create new bids.
      class CreateBidStandardContract < Contracts::ApplicationContract
        option :user_repo, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

        # @param [Hash] opts Sets an allowed list of parameters, as well as some initial validations.
        params do
          required(:auction_id).filled(:integer)
          required(:user_id).filled(:integer)
          required(:value_cents).filled(:integer)

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
            if context[:auction].kind != "standard"
              key.failure(I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "standard"))
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
        rule(:user_id) do |context:|
          context[:user] ||= user_repo.by_id(value)
          key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:user]
        end

        # Validation for value bid.
        # must be greater than or equal to the auction's minimal bid.
        rule(:value_cents) do |context:|
          standard_auction_valid_bid?(key, value, context[:auction].minimal_bid_cents)
        end

        private

        # Checks if the bid amount is greather than or equal to minimum bid.
        def standard_auction_valid_bid?(key, value_cents, minimal_bid_cents)
          return if value_cents >= minimal_bid_cents

          key.failure(I18n.t("contracts.errors.gteq?", num: Money.new(minimal_bid_cents).to_f))
        end
      end
    end
  end
end
