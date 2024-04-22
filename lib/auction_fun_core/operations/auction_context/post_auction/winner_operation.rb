# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PostAuction
        ##
        # Operation class for finish auctions.
        #
        class WinnerOperation < AuctionFunCore::Operations::Base
          include Import["repos.user_context.user_repository"]
          include Import["contracts.auction_context.post_auction.winner_contract"]
          include Import["workers.services.mail.auction_context.post_auction.winner_mailer_job"]

          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ## @todo Add doc
          def call(attributes)
            auction, winner = yield validate_contract(attributes)

            user_repository.transaction do |_t|
              send_winner_email_with_statistics_and_payment_instructions(auction.id, winner.id)
            end

            Success([auction, winner])
          end

          private

          def validate_contract(attributes)
            contract = winner_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success([contract.context[:auction], contract.context[:winner]])
          end

          def send_winner_email_with_statistics_and_payment_instructions(auction_id, winner_id)
            Success(winner_mailer_job.class.perform_async(auction_id, winner_id))
          end
        end
      end
    end
  end
end
