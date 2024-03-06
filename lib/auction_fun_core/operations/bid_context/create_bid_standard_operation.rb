# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module BidContext
      ##
      # Operation class for create new bids for standard auctions.
      #
      class CreateBidStandardOperation < AuctionFunCore::Operations::Base
        INCREASE = 0.1
        include Import["contracts.bid_context.create_bid_standard_contract"]
        include Import["repos.auction_context.auction_repository"]
        include Import["repos.bid_context.bid_repository"]

        # @todo Add custom doc
        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          values = yield validate(attributes)

          bid_repository.transaction do |_t|
            @bid = yield persist(values)
            yield calculate_standard_auction_new_minimal_bid_value(@bid.auction_id, @bid.value_cents)
            yield publish_bid_created(@bid)
          end

          Success(@bid)
        end

        # Calls the bid creation contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] bid attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate(attrs)
          contract = create_bid_standard_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.to_h)
        end

        # Calculates the new minimum next bid amount.
        def calculate_standard_auction_new_minimal_bid_value(auction_id, bid_cents)
          minimal_bid_cents = (bid_cents + (bid_cents * INCREASE))

          Success(auction_repository.update(auction_id, minimal_bid_cents: minimal_bid_cents))
        end

        # Calls the bid repository class to persist the attributes in the database.
        # @param result [Hash] Bid validated attributes
        # @return [ROM::Struct::Bid]
        def persist(result)
          Success(bid_repository.create(result))
        end

        # Triggers the publication of event *bids.created*.
        # @param bid [ROM::Struct::Bid] Bid Object
        # @return [Dry::Monads::Result::Success]
        def publish_bid_created(bid)
          Application[:event].publish("bids.created", bid.to_h)

          Success()
        end
      end
    end
  end
end
