# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module PreAuction
          ##
          # Background job class responsible for sending auction start reminders
          class AuctionStartReminderOperationJob < Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]
            include Import["repos.auction_context.auction_repository"]

            # Executes the auction start reminder operation for the specified auction.
            #
            # @param auction_id [Integer] The ID of the auction.
            # @param retry_count [Integer] The current retry count for the job.
            # @return [void]
            def perform(auction_id, retry_count = 0)
              auction = auction_repository.by_id!(auction_id)

              auction_start_reminder_operation.call(auction_id: auction.id)
            rescue => e
              capture_exception(e, {auction_id: auction_id, retry_count: retry_count})
              raise if retry_count >= MAX_RETRIES

              interval = backoff_exponential_job(retry_count)
              self.class.perform_at(interval, auction_id, retry_count + 1)
            end

            private

            # Retrieves the auction start reminder operation.
            #
            # @return [Class] The auction start reminder operation class.
            def auction_start_reminder_operation
              AuctionFunCore::Operations::AuctionContext::PreAuction::AuctionStartReminderOperation
            end
          end
        end
      end
    end
  end
end
