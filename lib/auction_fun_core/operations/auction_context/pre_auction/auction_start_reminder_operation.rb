# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PreAuction
        ##
        # Operation class for send a reminder email to a participant about the start of an auction.
        #
        class AuctionStartReminderOperation < AuctionFunCore::Operations::Base
          include Import["repos.bid_context.bid_repository"]
          include Import["contracts.auction_context.pre_auction.auction_start_reminder_contract"]
          include Import["workers.services.mail.auction_context.pre_auction.auction_start_reminder_mailer_job"]

          # @todo Add custom doc
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          def call(attributes)
            auction = yield validate_contract(attributes)
            participant_ids = yield collect_current_auction_participants(auction.id)

            bid_repository.transaction do |_t|
              participant_ids.each do |participant_id|
                yield send_auction_start_reminder_mailer_job(auction.id, participant_id)
              end
            end

            Success([auction, participant_ids])
          end

          private

          def validate_contract(attributes)
            contract = auction_start_reminder_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success(contract.context[:auction])
          end

          def collect_current_auction_participants(auction_id)
            Success(
              AuctionFunCore::Application[:container]
                .relations[:bids]
                .participants(auction_id)
                .one
                .participant_ids.to_a
            )
          end

          def send_auction_start_reminder_mailer_job(auction_id, participant_id)
            Success(auction_start_reminder_mailer_job.class.perform_async(auction_id, participant_id))
          end
        end
      end
    end
  end
end
