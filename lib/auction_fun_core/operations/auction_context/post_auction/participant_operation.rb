# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PostAuction
        ##
        # Operation class for finish auctions.
        #
        class ParticipantOperation < AuctionFunCore::Operations::Base
          include Import["repos.user_context.user_repository"]
          include Import["contracts.auction_context.post_auction.participant_contract"]
          include Import["workers.services.mail.auction_context.post_auction.participant_mailer_job"]

          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ## @todo Add more actions
          #   Send email to participant with auction statistics.
          def call(attributes)
            auction, participant = yield validate_contract(attributes)

            user_repository.transaction do |_t|
              yield send_participant_email_with_statistics_and_payment_instructions(auction.id, participant.id)
            end

            Success([auction, participant])
          end

          private

          def validate_contract(attributes)
            contract = participant_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success([contract.context[:auction], contract.context[:participant]])
          end

          def send_participant_email_with_statistics_and_payment_instructions(auction_id, participant_id)
            Success(participant_mailer_job.class.perform_async(auction_id, participant_id))
          end
        end
      end
    end
  end
end
