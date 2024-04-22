# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Operations
      module AuctionContext
        module PostAuction
          ##
          # BackgroundJob class for call finish auction operation.
          class ParticipantOperationJob < Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]
            include Import["repos.auction_context.auction_repository"]
            include Import["operations.auction_context.post_auction.participant_operation"]

            # @todo Add detailed documentation
            def perform(auction_id, participant_id, retry_count = 0)
              auction = auction_repository.by_id!(auction_id)
              participant = user_repository.by_id!(participant_id)

              participant_operation.call(auction_id: auction.id, participant_id: participant.id)
            rescue => e
              capture_exception(e, {auction_id: auction_id, participant_id: participant_id, retry_count: retry_count})
              raise if retry_count >= MAX_RETRIES

              interval = backoff_exponential_job(retry_count)
              self.class.perform_at(interval, auction_id, participant_id, retry_count + 1)
            end
          end
        end
      end
    end
  end
end
