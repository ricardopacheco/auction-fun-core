# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module BidContext
      # This class validates the creation of new bids for closed-type auctions.
      # It ensures the bid is placed by a valid user on a valid auction that is open for bids, and that
      # the bid value meets or exceeds the starting bid required by the auction.
      # Furthermore, only one bid per participant is allowed.
      #
      # @example Creating a bid for a closed auction
      #   contract = AuctionFunCore::Contracts::BidContext::CreateBidClosedContract.new
      #   attributes = { auction_id: 123, user_id: 2, value_cents: 10000 }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Bid created successfully."
      #   else
      #     puts "Failed to create bid: #{result.errors.to_h}"
      #   end
      class CreateBidClosedContract < Contracts::ApplicationContract
        # Repositories initialized to retrieve data for validation.
        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }
        option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
        option :bid_repository, default: proc { Repos::BidContext::BidRepository.new }

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

        # Validates the auction's validity and status for receiving bids.
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

        # Validates the user's existence and checks if they have already placed a bid.
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

        # Validates that the bid amount is greater than or equal to the auction's starting bid.
        rule(:value_cents) do |context:|
          unless rule_error?(:user_id)
            closed_auction_bid_value_is_gteq_initial_bid?(key, value, context[:auction].initial_bid_cents)
          end
        end

        private

        # Helper method to check if the bid amount meets the minimum required bid.
        def closed_auction_bid_value_is_gteq_initial_bid?(key, value_cents, minimal_bid_cents)
          return unless value_cents < minimal_bid_cents

          key.failure(I18n.t("contracts.errors.gteq?", num: Money.new(minimal_bid_cents).to_f))
        end
      end
    end
  end
end
