# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # This class validates the creation of new bids for penny-type auctions.
      # It guarantees that the bid can only be made within the correct status of this type of auction,
      # in addition, the participant must have sufficient balance in their wallet to place a new bid.
      #
      # @example Creating a bid for a penny auction
      #   contract = AuctionFunCore::Contracts::BidContext::CreateBidPennyContract.new
      #   attributes = { auction_id: 123, user_id: 2 }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Bid created successfully."
      #   else
      #     puts "Failed to create bid: #{result.errors.to_h}"
      #   end
      class CreateBidPennyContract < Contracts::ApplicationContract
        # Repositories initialized to retrieve data for validation.
        option :user_repo, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:auction_id).filled(:integer)
          required(:user_id).filled(:integer)

          # Keys with a blank value are discarded.
          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Validates the auction's validity, kind, and status for receiving bids.
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

        # Validates the user's existence and ensures they have enough balance to bid.
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

        # Helper method to check if the user has sufficient balance to place a bid in a penny auction.
        def penny_auction_check_user_has_balance?(key, auction_bid_cents, balance_cents)
          key.failure(I18n.t("contracts.errors.custom.bids.insufficient_balance")) if balance_cents < auction_bid_cents
        end
      end
    end
  end
end
