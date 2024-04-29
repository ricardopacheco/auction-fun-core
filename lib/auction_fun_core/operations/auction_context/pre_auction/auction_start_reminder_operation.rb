# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PreAuction
        ##
        # Operation class for sending a reminder email to a participant about the start of an auction.
        #
        class AuctionStartReminderOperation < AuctionFunCore::Operations::Base
          include Import["repos.bid_context.bid_repository"]
          include Import["contracts.auction_context.pre_auction.auction_start_reminder_contract"]
          include Import["workers.services.mail.auction_context.pre_auction.auction_start_reminder_mailer_job"]

          ##
          # Executes the auction start reminder operation with the provided attributes.
          #
          # @param attributes [Hash] The attributes for the auction start reminder operation.
          # @yield [Dry::Matcher::Evaluator] The block to handle the result of the operation.
          # @return [Dry::Matcher::Evaluator] The result of the operation.
          #
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ##
          # Executes the auction start reminder operation.
          #
          # @param attributes [Hash] The attributes for the auction start reminder operation.
          # @return [Dry::Monads::Result] The result of the operation.
          #
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

          ##
          # Validates the contract with the provided attributes.
          #
          # @param attributes [Hash] The attributes to validate.
          # @option auction_id [Integer] The ID of the auction.
          # @return [Dry::Monads::Result] The result of the validation.
          #
          def validate_contract(attributes)
            contract = auction_start_reminder_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success(contract.context[:auction])
          end

          ##
          # Collects the participant IDs for the current auction.
          #
          # @param auction_id [Integer] The ID of the auction.
          # @return [Dry::Monads::Result] The result of collecting the participant IDs.
          #
          def collect_current_auction_participants(auction_id)
            Success(
              AuctionFunCore::Application[:container]
                .relations[:bids]
                .participants(auction_id)
                .one
                .participant_ids.to_a
            )
          end

          ##
          # Sends the auction start reminder email to a participant.
          #
          # @param auction_id [Integer] The ID of the auction.
          # @param participant_id [Integer] The ID of the participant.
          # @return [Dry::Monads::Result] The result of sending the email.
          #
          def send_auction_start_reminder_mailer_job(auction_id, participant_id)
            Success(auction_start_reminder_mailer_job.class.perform_async(auction_id, participant_id))
          end
        end
      end
    end
  end
end
