# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module BidContext
      ##
      # Operation class for create new bids for penny auctions.
      #
      class CreateBidPennyOperation < AuctionFunCore::Operations::Base
        include Import["repos.bid_context.bid_repository"]
        include Import["repos.auction_context.auction_repository"]
        include Import["contracts.bid_context.create_bid_penny_contract"]
        include Import["workers.operations.auction_context.processor.finish.penny_operation_job"]

        # @todo Add custom doc
        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          auction, values = yield validate_contract(attributes)

          bid_repository.transaction do |_t|
            @bid = yield persist(values)
            updated_auction = yield update_end_auction(auction)

            yield reschedule_end_auction(updated_auction)
            yield publish_bid_created(@bid)
          end

          Success(@bid)
        end

        # Calls the bid creation contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] bid attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = create_bid_penny_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success([contract.context[:auction], contract.to_h])
        end

        # Updates the end time of an auction if it has already started.
        #
        # This method checks whether an auction is currently running. If the auction is running,
        # it calculates a new end time based on the current time and the duration specified
        # by the auction's stopwatch. The auction's finish time is then updated in the repository.
        # If the auction has not started, it returns the auction as is without any modifications.
        #
        # @param auction [ROM::Struct::Auction] An instance of Auction to be checked and potentially updated.
        # @return [Dry::Monads::Result::Success<ROM::Struct::Auction>, Dry::Monads::Result::Failure]
        def update_end_auction(auction)
          return Success(auction) unless started_auction?(auction)

          updated_attributes = {
            finished_at: Time.current + auction.stopwatch.seconds,
            kind: auction.kind,
            status: auction.status
          }

          updated_auction, _ = auction_repository.update(auction.id, updated_attributes)

          Success(updated_auction)
        end

        # Calls the bid repository class to persist the attributes in the database.
        # @param result [Hash] Bid validated attributes
        # @return [Dry::Monads::Result::Success<ROM::Struct::Bid>, Dry::Monads::Result::Failure]
        def persist(values)
          Success(bid_repository.create(values))
        end

        # Triggers the publication of event *bids.created*.
        # @param bid [ROM::Struct::Bid] Bid Object
        # @return [Dry::Monads::Result::Success]
        def publish_bid_created(bid)
          Application[:event].publish("bids.created", bid.to_h)

          Success()
        end

        # TODO: Added a small delay to perform operations (such as sending broadcasts and/or other operations).
        # Reschedules the end time of an auction's background job if the auction has already started.
        #
        # This method checks if the auction is running. If so, it schedules a background job to
        # execute at the auction's current finish time using the job class defined by the
        # penny_operation_job attribute of the auction. If the auction has not started, it
        # simply returns a Success object with no parameters.
        #
        # @return [Dry::Monads::Result::Success<ROM::Struct::Auction>, Dry::Monads::Result::Success<String>]
        def reschedule_end_auction(auction)
          # binding.pry
          return Success(auction) unless started_auction?(auction)

          perform_at = auction.finished_at

          Success(penny_operation_job.class.perform_at(perform_at, auction.id))
        end

        def started_auction?(auction)
          auction.status == "running"
        end
      end
    end
  end
end
