# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module PostAuction
        ##
        # Operation class for managing winners in auctions.
        #
        class WinnerOperation < AuctionFunCore::Operations::Base
          include Import["repos.user_context.user_repository"]
          include Import["contracts.auction_context.post_auction.winner_contract"]
          include Import["workers.services.mail.auction_context.post_auction.winner_mailer_job"]

          ##
          # Executes the winner operation with the provided attributes.
          #
          # @param attributes [Hash] The attributes for the winner operation.
          # @option attributes auction_id [Integer] The ID of the auction.
          # @option attributes winner_id [Integer] The winning user ID
          # @yield [Dry::Matcher::Evaluator] The block to handle the result of the operation.
          # @return [Dry::Matcher::Evaluator] The result of the operation.
          #
          # @example
          #   attributes = { auction_id: 123, winner_id: 123 }
          #
          #   AuctionFunCore::Operations::AuctionContext::PostAuction::WinnerOperation.call(attributes) do |result|
          #     result.success { |auction| puts "Winner operation completed successfully! #{auction.to_h}" }
          #     result.failure { |failure| puts "Failed auction winner operation: #{failure.errors.to_h}"}
          #   end
          def self.call(attributes, &block)
            operation = new.call(attributes)

            return operation unless block

            Dry::Matcher::ResultMatcher.call(operation, &block)
          end

          ##
          # Executes the winner operation.
          #
          # @param attributes [Hash] The attributes for the winner operation.
          # @return [Dry::Monads::Result] The result of the operation.
          #
          def call(attributes)
            auction, winner = yield validate_contract(attributes)

            user_repository.transaction do |_t|
              send_winner_email_with_statistics_and_payment_instructions(auction.id, winner.id)
            end

            Success([auction, winner])
          end

          private

          ##
          # Validates the contract with the provided attributes.
          #
          # @param attributes [Hash] The attributes to validate.
          # @return [Dry::Monads::Result] The result of the validation.
          #
          def validate_contract(attributes)
            contract = winner_contract.call(attributes)

            return Failure(contract.errors.to_h) if contract.failure?

            Success([contract.context[:auction], contract.context[:winner]])
          end

          ##
          # Sends winner email with auction statistics and payment instructions.
          #
          # @param auction_id [Integer] The ID of the auction.
          # @param winner_id [Integer] The ID of the winner.
          # @return [Dry::Monads::Result] The result of sending the email.
          #
          def send_winner_email_with_statistics_and_payment_instructions(auction_id, winner_id)
            Success(winner_mailer_job.class.perform_async(auction_id, winner_id))
          end
        end
      end
    end
  end
end
