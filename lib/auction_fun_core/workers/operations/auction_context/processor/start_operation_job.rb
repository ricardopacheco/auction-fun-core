# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module Processor
          ##
          # BackgroundJob class for call start auction operation.
          #
          class StartOperationJob < AuctionFunCore::Workers::ApplicationJob
            include Import["repos.auction_context.auction_repository"]
            include Import["operations.auction_context.processor.start_operation"]

            # @todo Add detailed documentation
            def perform(auction_id, retry_count = 0)
              auction = auction_repository.by_id!(auction_id)

              start_operation.call(auction_id: auction.id, kind: auction.kind, stopwatch: auction.stopwatch)
            rescue => e
              capture_exception(e, {auction_id: auction_id, retry_count: retry_count})
              raise if retry_count >= MAX_RETRIES

              interval = backoff_exponential_job(retry_count)
              self.class.perform_at(interval, auction_id, retry_count + 1)
            end
          end
        end
      end
    end
  end
end
