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
            class WinnerMailerJob < AuctionFunCore::Workers::ApplicationJob
              include Import["repos.user_context.user_repository"]
              include Import["repos.auction_context.auction_repository"]

              # @param auction_id [Integer] auction ID
              # @param winner_id [Integer] user ID
              def perform(auction_id, winner_id, retry_count = 0)
                auction = auction_repository.by_id!(auction_id)
                winner = user_repository.by_id!(winner_id)

                statistics = relation.load_winner_statistics.call(auction_id, winner_id).first

                winner_mailer.new(auction, winner, statistics).deliver
              rescue => e
                capture_exception(e, {auction_id: auction_id, winner_id: winner_id, retry_count: retry_count})
                raise e if retry_count >= MAX_RETRIES

                interval = backoff_exponential_job(retry_count)
                self.class.perform_at(interval, auction_id, winner_id, retry_count + 1)
              end

              private

              # Since the shipping code structure does not follow project conventions,
              # making the default injection dependency would be more complicated.
              # Therefore, here I directly explain the class to be called.
              def winner_mailer
                AuctionFunCore::Services::Mail::AuctionContext::PostAuction::WinnerMailer
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
