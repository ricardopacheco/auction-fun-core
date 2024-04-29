# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # This class validates the creation of new bids for standard-type auctions.
      # It ensures the bid is placed by a valid user on a valid auction that is open for bids,
      # and that the bid value meets or exceeds the minimum bid required by the auction.
      #
      # @example Creating a bid for a standard auction
      #   contract = AuctionFunCore::Contracts::BidContext::CreateBidStandardContract.new
      #   attributes = { auction_id: 1, user_id: 2, value_cents: 5000 }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Bid created successfully."
      #   else
      #     puts "Failed to create bid: #{result.errors.to_h}"
      #   end
      class CreateBidStandardContract < Contracts::ApplicationContract
        # Repositories initialized to retrieve data for validation.
        option :user_repo, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repo, default: proc { Repos::AuctionContext::AuctionRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:auction_id).filled(:integer)
          required(:user_id).filled(:integer)
          required(:value_cents).filled(:integer)

          # Keys with a blank value are discarded.
          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Validates the auction's validity, kind, and status for receiving bids.
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

        # Validates the user's existence in the database.
        rule(:user_id) do |context:|
          context[:user] ||= user_repo.by_id(value)
          key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:user]
        end

        # Validates that the bid amount is greater than or equal to the auction's minimum bid.
        rule(:value_cents) do |context:|
          standard_auction_valid_bid?(key, value, context[:auction].minimal_bid_cents)
        end

        private

        # Helper method to check if the bid amount meets the minimum required bid.
        def standard_auction_valid_bid?(key, value_cents, minimal_bid_cents)
          return if value_cents >= minimal_bid_cents

          key.failure(I18n.t("contracts.errors.gteq?", num: Money.new(minimal_bid_cents).to_f))
        end
      end
    end
  end
end
