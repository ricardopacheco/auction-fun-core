# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module Processor
          module Finish
            ##
            # BackgroundJob class for call finish standard auction operation.
            #
            class StandardOperationJob < Workers::ApplicationJob
              include Import["repos.auction_context.auction_repository"]
              include Import["operations.auction_context.processor.finish.standard_operation"]

              # @todo Add detailed documentation
              def perform(auction_id, retry_count = 0)
                auction = auction_repository.by_id!(auction_id)

                standard_operation.call(auction_id: auction.id)
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
end
