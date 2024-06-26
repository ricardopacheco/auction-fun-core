# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        ##
        # Operation class for dispatch unpause auction.
        # By default, this change auction status from 'paused' to 'running'.
        #
        class UnpauseOperation < AuctionFunCore::Operations::Base
          include Import["repos.auction_context.auction_repository"]
          include Import["contracts.auction_context.processor.unpause_contract"]

          ##
          # Executes the unpause operation with the provided attributes.
          #
          # @param attributes [Hash] The attributes for the unpause operation.
          # @option attributes auction_id [Integer] The ID of the auction.
          # @yield [Dry::Matcher::Evaluator] The block to handle the result of the operation.
          # @return [Dry::Matcher::Evaluator] The result of the operation.
          #
          # @example
          #   attributes = { auction_id: 123 }
          #
          #   AuctionFunCore::Operations::AuctionContext::Processor::UnpauseOperation.call(attributes) do |result|
          #     result.success { |auction| puts "Unpaused auction sucessfully! #{auction.to_h}" }
          #     result.failure { |failure| puts "Failed to unpause auction: #{failure.errors.to_h}"}
          #   end
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ##
          # Performs the unpause of an auction.
          #
          # @param attributes [Hash] The attributes for the unpause operation.
          # @option attributes auction_id [Integer] The ID of the auction.
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure] The result of the operation.
          #
          # @example
          #   attributes = { auction_id: 123 }
          #
          #   operation = AuctionFunCore::Operations::AuctionContext::Processor::UnpauseOperation.call(attributes)
          #
          #   if operation.success?
          #     auction = operation.success
          #     puts "Unpaused auction sucessfully! #{auction.to_h}"
          #   end
          #
          #   if operation.failure?
          #     failure = operation.failure
          #     puts "Failed to unpause auction: #{failure.errors.to_h}"
          #   end
          def call(attributes)
            attrs = yield validate(attributes)

            auction_repository.transaction do |_t|
              @auction, _ = auction_repository.update(attrs[:auction_id], status: "running")

              publish_auction_unpause_event(@auction)
            end

            Success(attrs[:auction_id])
          end

          private

          # Calls the unpause contract class to perform the validation
          # of the informed attributes.
          # @param attrs [Hash] auction attributes
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
          def validate(attributes)
            contract = unpause_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success(contract.to_h)
          end

          def publish_auction_unpause_event(auction)
            Application[:event].publish("auctions.unpaused", auction.to_h)
          end
        end
      end
    end
  end
end
