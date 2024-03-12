# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        ##
        # Operation class for dispatch pause auction.
        # By default, this change auction status from 'running' to 'paused'.
        #
        class PauseOperation < AuctionFunCore::Operations::Base
          include Import["repos.auction_context.auction_repository"]
          include Import["contracts.auction_context.processor.pause_contract"]

          # @todo Add custom doc
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          def call(attributes)
            attrs = yield validate(attributes)

            auction_repository.transaction do |_t|
              @auction, _ = auction_repository.update(attrs[:auction_id], status: "paused")

              publish_auction_pause_event(@auction)
            end

            Success(attrs[:auction_id])
          end

          private

          # Calls the finish contract class to perform the validation
          # of the informed attributes.
          # @param attrs [Hash] auction attributes
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
          def validate(attributes)
            contract = pause_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success(contract.to_h)
          end

          def publish_auction_pause_event(auction)
            Application[:event].publish("auctions.paused", auction.to_h)
          end
        end
      end
    end
  end
end
