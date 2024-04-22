# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Services
      module Mail
        module AuctionContext
          module PostAuction
            ##
            # Background job class responsible for adding emails to the queue.
            #
            class ParticipantMailerJob < AuctionFunCore::Workers::ApplicationJob
              include Import["repos.user_context.user_repository"]
              include Import["repos.auction_context.auction_repository"]

              # @param auction_id [Integer] auction ID
              # @param participant_id [Integer] user ID
              def perform(auction_id, participant_id, retry_count = 0)
                auction = auction_repository.by_id!(auction_id)
                participant = user_repository.by_id!(participant_id)

                statistics = relation.load_participant_statistics.call(auction.id, participant.id).first

                participant_mailer.new(auction, participant, statistics).deliver
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
              def participant_mailer
                AuctionFunCore::Services::Mail::AuctionContext::PostAuction::ParticipantMailer
              end

              def relation
                AuctionFunCore::Application[:container].relations[:auctions]
              end
            end
          end
        end
      end
    end
  end
end
