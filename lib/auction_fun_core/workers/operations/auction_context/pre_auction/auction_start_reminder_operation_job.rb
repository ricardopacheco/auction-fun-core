# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module PreAuction
          ##
          # BackgroundJob class for call auction start reminder operation.
          class AuctionStartReminderOperationJob < Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]
            include Import["repos.auction_context.auction_repository"]

            # @todo Add detailed documentation
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

            # Since the shipping code structure does not follow project conventions,
            # making the default injection dependency would be more complicated.
            # Therefore, here I directly explain the class to be called.
            def auction_start_reminder_operation
              AuctionFunCore::Operations::AuctionContext::PreAuction::AuctionStartReminderOperation
            end
          end
        end
      end
    end
  end
end
