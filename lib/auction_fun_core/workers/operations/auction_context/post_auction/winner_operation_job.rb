# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module PostAuction
          ##
          # Background job class responsible for performing winner operations after an finished auction.
          class WinnerOperationJob < Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]
            include Import["repos.auction_context.auction_repository"]
            include Import["operations.auction_context.post_auction.winner_operation"]

            # Executes the winner operation for the specified auction and winner.
            #
            # @param auction_id [Integer] The ID of the auction.
            # @param winner_id [Integer] The ID of the winner.
            # @param retry_count [Integer] The current retry count for the job.
            def perform(auction_id, winner_id, retry_count = 0)
              auction = auction_repository.by_id!(auction_id)
              winner = user_repository.by_id!(winner_id)

              winner_operation.call(auction_id: auction.id, winner_id: winner.id)
            rescue => e
              capture_exception(e, {auction_id: auction_id, winner_id: winner_id, retry_count: retry_count})
              raise if retry_count >= MAX_RETRIES

              interval = backoff_exponential_job(retry_count)
              self.class.perform_at(interval, auction_id, winner_id, retry_count + 1)
            end
          end
        end
      end
    end
  end
end
