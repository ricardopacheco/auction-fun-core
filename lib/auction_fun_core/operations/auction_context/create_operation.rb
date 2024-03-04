# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      ##
      # Operation class for creating auctions.
      #
      class CreateOperation < AuctionFunCore::Operations::Base
        include Import["repos.auction_context.auction_repository"]
        include Import["contracts.auction_context.create_contract"]
        include Import["workers.operations.auction_context.processor.start_operation_job"]

        # @todo Add custom doc
        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        def call(attributes)
          values = yield validate(attributes)

          auction_repository.transaction do |_t|
            @auction = yield persist(values)
            yield scheduled_start_auction(@auction)
            yield publish_auctions_created(@auction)
          end

          Success(@auction)
        end

        private

        # Calls the auction creation contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] auction attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate(attrs)
          contract = create_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.to_h)
        end

        # Calls the auction repository class to persist the attributes in the database.
        # @param result [Hash] Auction validated attributes
        # @return [ROM::Struct::Auction]
        def persist(result)
          Success(auction_repository.create(result))
        end

        # Triggers the publication of event *auctions.created*.
        # @param auction [Hash] Auction persisted attributes
        # @return [Dry::Monads::Result::Success]
        def publish_auctions_created(auction)
          Application[:event].publish("auctions.created", auction.to_h)

          Success()
        end

        # Calls the background job class that will schedule the start of the auction.
        # Added a small delay to perform operations (such as sending broadcasts and/or other operations).
        # @param auction [ROM::Struct::Auction]
        # @return [String] sidekiq jid
        def scheduled_start_auction(auction)
          perform_at = auction.started_at

          Success(start_operation_job.class.perform_at(perform_at, auction.id))
        end
      end
    end
  end
end
