# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module Processor
          module Finish
            ##
            # Background job class responsible for call finish penny auction operation.
            class PennyOperationJob < Workers::ApplicationJob
              include Sidekiq::Worker
              include Import["repos.auction_context.auction_repository"]
              include Import["operations.auction_context.processor.finish.penny_operation"]

              sidekiq_options queue: "default", lock: :until_executed, on_conflict: :replace

              # Executes the operation to finish a penny auction.
              #
              # @param auction_id [Integer] The ID of the penny auction.
              # @param retry_count [Integer] The current retry count for the job.
              # @return [void]
              def perform(auction_id, retry_count = 0)
                auction = auction_repository.by_id!(auction_id)

                penny_operation.call(auction_id: auction.id)
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
