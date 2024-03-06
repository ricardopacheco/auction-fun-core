# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # Contract class to create new bids.
      class CreateBidClosedContract < Contracts::ApplicationContract
        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
        option :bid_repository, default: proc { Repos::BidContext::BidRepository.new }

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
          context[:auction] ||= auction_repository.by_id(value)

          if context[:auction]
            if context[:auction].kind != "closed"
              key.failure(I18n.t("contracts.errors.custom.bids.invalid_kind", kind: "closed"))
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
        # Validates if user has already placed a bid
        rule(:user_id) do |context:|
          context[:user] ||= user_repository.by_id(value)

          if context[:user]
            if bid_repository.exists?(auction_id: values[:auction_id], user_id: value)
              key.failure(I18n.t("contracts.errors.custom.bids.already_bidded"))
            end
          else
            key.failure(I18n.t("contracts.errors.custom.not_found"))
          end
        end

        # Validation for value bid.
        # The bid amount must be greater than or equal to the starting bid.
        rule(:value_cents) do |context:|
          unless rule_error?(:user_id)
            closed_auction_bid_value_is_gteq_initial_bid?(key, value, context[:auction].initial_bid_cents)
          end
        end

        private

        # Checks if bid amount must be greater than or equal to the starting bid.
        def closed_auction_bid_value_is_gteq_initial_bid?(key, value_cents, minimal_bid_cents)
          return unless value_cents < minimal_bid_cents

          key.failure(I18n.t("contracts.errors.gteq?", num: Money.new(minimal_bid_cents).to_f))
        end
      end
    end
  end
end
