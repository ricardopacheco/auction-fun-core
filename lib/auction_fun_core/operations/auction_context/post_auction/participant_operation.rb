# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PostAuction
        ##
        # Operation class for managing participants in auctions.
        #
        class ParticipantOperation < AuctionFunCore::Operations::Base
          include Import["repos.user_context.user_repository"]
          include Import["contracts.auction_context.post_auction.participant_contract"]
          include Import["workers.services.mail.auction_context.post_auction.participant_mailer_job"]

          ##
          # Executes the participant operation with the provided attributes.
          #
          # @param attributes [Hash] The attributes for the winner operation.
          # @option attributes auction_id [Integer] The ID of the auction.
          # @option attributes participant_id [Integer] The participating user ID.
          # @yield [Dry::Matcher::Evaluator] The block to handle the result of the operation.
          # @return [Dry::Matcher::Evaluator] The result of the operation.
          #
          # @example
          #   attributes = { auction_id: 123, participant_id: 123 }
          #
          #   AuctionFunCore::Operations::AuctionContext::PostAuction::ParticipantOperation.call(attributes) do |result|
          #     result.success { |auction| puts "Participation operation completed successfully! #{auction.to_h}" }
          #     result.failure { |failure| puts "Failed auction participation operation: #{failure.errors.to_h}"}
          #   end
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ##
          # Executes the participant operation.
          #
          # @param attributes [Hash] The attributes for the participant operation.
          # @return [Dry::Monads::Result] The result of the operation.
          #
          def call(attributes)
            auction, participant = yield validate_contract(attributes)

            user_repository.transaction do |_t|
              yield send_participant_email_with_statistics_and_payment_instructions(auction.id, participant.id)
            end

            Success([auction, participant])
          end

          private

          ##
          # Validates the contract with the provided attributes.
          #
          # @param attributes [Hash] The attributes to validate.
          # @return [Dry::Monads::Result] The result of the validation.
          #
          def validate_contract(attributes)
            contract = participant_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success([contract.context[:auction], contract.context[:participant]])
          end

          ##
          # Sends participant email with auction statistics and payment instructions.
          #
          # @param auction_id [Integer] The ID of the auction.
          # @param participant_id [Integer] The ID of the participant.
          # @return [Dry::Monads::Result] The result of sending the email.
          #
          def send_participant_email_with_statistics_and_payment_instructions(auction_id, participant_id)
            Success(participant_mailer_job.class.perform_async(auction_id, participant_id))
          end
        end
      end
    end
  end
end
