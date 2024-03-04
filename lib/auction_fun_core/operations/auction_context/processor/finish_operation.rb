# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        ##
        # Operation class for dispatch finish auction.
        # By default, this change auction status from 'running' to 'finished'.
        #
        class FinishOperation < AuctionFunCore::Operations::Base
          include Import["repos.auction_context.auction_repository"]
          include Import["contracts.auction_context.processor.finish_contract"]

          # @todo Add custom doc
          def self.call(auction_id, &block)
            operation = new.call(auction_id)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          # @todo Add more actions
          #   Generate auction statistics and save in JSONB (statistics field)
          #   Send email to winner with payment info.
          #   Send email for bidders with user bid stats
          def call(auction_id)
            yield validate(auction_id: auction_id)

            auction_repository.transaction do |_t|
              @auction, _ = auction_repository.update(auction_id, status: "finished")

              publish_auction_finish_event(@auction)
            end

            Success(@auction)
          end

          private

          # Calls the finish contract class to perform the validation
          # of the informed attributes.
          # @param attributes [Hash] auction attributes
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
          def validate(attributes)
            contract = finish_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success(contract.to_h)
          end

          def publish_auction_finish_event(auction)
            Application[:event].publish("auctions.finished", auction.to_h)
          end
        end
      end
    end
  end
end
