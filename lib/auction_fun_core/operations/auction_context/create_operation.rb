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
        include Import["workers.operations.auction_context.pre_auction.auction_start_reminder_operation_job"]

        # @todo Add custom doc
        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        def call(attributes)
          values = yield validate_contract(attributes)
          values = yield assign_default_values(values)

          auction_repository.transaction do |_t|
            @auction = yield persist(values)
            yield scheduled_start_auction(@auction)
            yield schedule_auction_notification(@auction)
            yield publish_auctions_created(@auction)
          end

          Success(@auction)
        end

        private

        # Calls the auction creation contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] auction attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = create_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.to_h)
        end

        # By default, the auction status is set to 'scheduled'.
        # @todo Refactor this method in the future to consider the status as of the auction start date.
        # @param attrs [Hash] auction attributes
        # @return [Dry::Monads::Result::Success]
        def assign_default_values(attrs)
          attrs[:status] = "scheduled"
          Success(attrs)
        end

        # Calls the auction repository class to persist the attributes in the database.
        # @param result [Hash] Auction validated attributes
        # @return [ROM::Struct::Auction]
        def persist(result)
          Success(auction_repository.create(result))
        end

        # Calls the background job class that will schedule the start of the auction.
        # Added a small delay to perform operations (such as sending broadcasts and/or other operations).
        # @param auction [ROM::Struct::Auction]
        # @return [String] sidekiq jid
        def scheduled_start_auction(auction)
          perform_at = auction.started_at

          Success(start_operation_job.class.perform_at(perform_at, auction.id))
        end

        # Schedules a notification to be sent to users one hour before the auction starts.
        # The scheduling is only done if the start of the auction is more than one hour ahead of the current time,
        # ensuring that there is sufficient time for the notification to be sent.
        #
        # @param auction [ROM::Struct::Auction]
        # @return [String] sidekiq jid
        def schedule_auction_notification(auction)
          perform_time = auction.started_at - 1.hour

          return Success() if perform_time <= Time.current

          Success(auction_start_reminder_operation_job.class.perform_at(perform_time, auction.id))
        end

        # Triggers the publication of event *auctions.created*.
        # @param auction [ROM::Struct::Auction]
        # @return [Dry::Monads::Result::Success]
        def publish_auctions_created(auction)
          Application[:event].publish("auctions.created", auction.to_h)

          Success()
        end
      end
    end
  end
end
