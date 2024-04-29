# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      module PostAuction
        ##
        # This class is used to validate the participation of users in an auction.
        # This contract ensures that both the auction and the participant exist and that the participant
        # has already at least placed a bid. It utilizes repositories to fetch data about auctions, users, and bids.
        #
        # @example Using this class to validate a participant
        #   contract = AuctionFunCore::Contracts::AuctionContext::PostAuction::ParticipantContract.new
        #   attributes = { auction_id: 1, participant_id: 102 }
        #   validation_result = contract.call(attributes)
        #   if validation_result.success?
        #     puts "Participant validation passed"
        #   else
        #     puts "Participant validation failed: #{validation_result.errors.to_h}"
        #   end
        #
        class ParticipantContract < Contracts::ApplicationContract
          # Scope for internationalization (i18n) entries specific to errors in this contract.
          I18N_SCOPE = "contracts.errors.custom.auction_context.post_auction.participation"

          # Repository options initialized by default. These repositories handle data retrieval.
          option :auction_repository, default: proc { Repos::AuctionContext::AuctionRepository.new }
          option :user_repository, default: proc { Repos::UserContext::UserRepository.new }
          option :bid_repository, default: proc { Repos::BidContext::BidRepository.new }

          # Defines the data types and required fields for the contract.
          params do
            required(:auction_id).filled(:integer)
            required(:participant_id).filled(:integer)
          end

          # Validation rule for auction_id to ensure the auction exists.
          # @param context [Hash] Optional context hash to store data and state during validation.
          rule(:auction_id) do |context:|
            context[:auction] ||= auction_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:auction]
          end

          # Validation rule for participant_id to ensure the participant exists.
          # @param context [Hash] Optional context hash to store data and state during validation.
          rule(:participant_id) do |context:|
            context[:participant] ||= user_repository.by_id(value)
            key.failure(I18n.t("contracts.errors.custom.not_found")) unless context[:participant]
          end

          # Combined validation rule for auction_id and participant_id to check that the participant
          # has not already placed a bid in the auction.
          # @param context [Hash] Context containing the auction and participant objects.
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
