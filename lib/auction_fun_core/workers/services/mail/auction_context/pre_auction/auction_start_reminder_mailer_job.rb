# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Services
      module Mail
        module AuctionContext
          module PreAuction
            ##
            # Background job class responsible for adding emails to the queue.
            #
            class AuctionStartReminderMailerJob < AuctionFunCore::Workers::ApplicationJob
              include Import["repos.user_context.user_repository"]
              include Import["repos.auction_context.auction_repository"]

              # @param auction_id [Integer] auction ID
              # @param participant_id [Integer] user ID
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

              # Since the shipping code structure does not follow project conventions,
              # making the default injection dependency would be more complicated.
              # Therefore, here I directly explain the class to be called.
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
