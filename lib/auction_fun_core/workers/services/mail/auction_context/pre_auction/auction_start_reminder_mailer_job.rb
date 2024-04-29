# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Services
      module Mail
        module AuctionContext
          module PreAuction
            ##
            # Background job class responsible for adding auction start emails to the queue.
            class AuctionStartReminderMailerJob < AuctionFunCore::Workers::ApplicationJob
              include Import["repos.user_context.user_repository"]
              include Import["repos.auction_context.auction_repository"]

              # Executes the operation of sending an email to the participant notifying
              # them of the start of the auction.
              #
              # @param auction_id [Integer] The ID of the standard auction.
              # @param participant_id [Integer] The ID of the participant
              # @param retry_count [Integer] The current retry count for the job.
              # @return [void]
              def perform(auction_id, participant_id, retry_count = 0)
                auction = auction_repository.by_id!(auction_id)
                participant = user_repository.by_id!(participant_id)

                auction_start_reminder_mailer.new(auction, participant).deliver
              rescue => e
                capture_exception(e, {auction_id: auction_id, participant_id: participant_id, retry_count: retry_count})
                raise e if retry_count >= MAX_RETRIES

                interval = backoff_exponential_job(retry_count)
                self.class.perform_at(interval, auction_id, participant_id, retry_count + 1)
              end

              private

              # Directly specifies the class to be called due to non-standard dependency injection.
              # @return [Class] The auction start reminder mailer class.
              def auction_start_reminder_mailer
                AuctionFunCore::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailer
              end
            end
          end
        end
      end
    end
  end
end
