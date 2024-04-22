# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        ##
        # Operation class for dispatch start auction.
        # By default, this change auction status from 'scheduled' to 'running'
        # and schedule a job to execute the auction finalization when auction is not penny.
        class StartOperation < AuctionFunCore::Operations::Base
          include Import["repos.auction_context.auction_repository"]
          include Import["contracts.auction_context.processor.start_contract"]
          include Import["workers.operations.auction_context.processor.finish.closed_operation_job"]
          include Import["workers.operations.auction_context.processor.finish.penny_operation_job"]
          include Import["workers.operations.auction_context.processor.finish.standard_operation_job"]

          # @todo Add custom doc
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          # @param [Hash] attributes needed to start a auction
          # @option opts [String] :auction_id auction id
          # @option opts [String] :auction_kind auction kind
          # @option opts [Integer] :stopwatch auction stopwatch
          # @return [ROM::Struct::Auction] auction object
          def call(attributes)
            auction, attrs = yield validate_contract(attributes)

            auction_repository.transaction do |_t|
              @auction, _ = auction_repository.update(auction.id, update_params(auction, attrs))

              yield publish_auction_start_event(@auction)
              yield scheduled_finished_auction(@auction)
            end

            Success(@auction)
          end

          private

          # Calls the start contract class to perform the validation
          # of the informed attributes.
          # @param attributes [Hash] auction attributes
          # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
          def validate_contract(attributes)
            contract = start_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success([contract.context[:auction], contract.to_h])
          end

          # Updates the status of the auction and depending on the type of auction,
          # it already sets the final date.
          # @param attrs [Hash] auction attributes
          # @return [Hash]
          def update_params(auction, attrs)
            return {kind: auction.kind, status: "running"} unless attrs[:kind] == "penny"

            {kind: auction.kind, status: "running", finished_at: attrs[:stopwatch].seconds.from_now}
          end

          def publish_auction_start_event(auction)
            Success(Application[:event].publish("auctions.started", auction.to_h))
          end

          # TODO: Added a small delay to perform operations (such as sending broadcasts and/or other operations).
          # Calls the background job class that will schedule the finish of the auction.
          # In the case of the penny auction, the end of the auction occurs after the first timer resets.
          # @param auction [ROM::Struct::Auction]
          # @return [String] sidekiq jid
          def scheduled_finished_auction(auction)
            perform_at = auction.finished_at

            case auction.kind
            in "penny"
              perform_at = auction.started_at + auction.stopwatch.seconds

              Success(penny_operation_job.class.perform_at(perform_at, auction.id))
            in "standard"
              Success(standard_operation_job.class.perform_at(perform_at, auction.id))
            in "closed"
              Success(closed_operation_job.class.perform_at(perform_at, auction.id))
            end
          end
        end
      end
    end
  end
end
