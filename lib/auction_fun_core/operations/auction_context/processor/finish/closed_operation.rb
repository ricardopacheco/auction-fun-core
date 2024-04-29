# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        module Finish
          ##
          # Operation class for finalizing a closed auction.
          # By default, this changes the auction status from 'running' to 'finished'.
          #
          class ClosedOperation < AuctionFunCore::Operations::Base
            include Import["repos.auction_context.auction_repository"]
            include Import["contracts.auction_context.processor.finish.closed_contract"]
            include Import["workers.operations.auction_context.post_auction.winner_operation_job"]
            include Import["workers.operations.auction_context.post_auction.participant_operation_job"]

            ##
            # Executes the closed operation with the provided attributes.
            #
            # @param attributes [Hash] The attributes for the closed operation.
            # @option attributes auction_id [Integer] The ID of the auction.
            # @yield [Dry::Matcher::Evaluator] The block to handle the result of the operation.
            # @return [Dry::Matcher::Evaluator] The result of the operation.
            #
            # @example
            #   attributes = { auction_id: 123 }
            #
            #   AuctionFunCore::Operations::AuctionContext::Processor::Finish::ClosedOperation.call(attributes) do |result|
            #     result.success { |auction| puts "Finished closed auction sucessfully! #{auction.to_h}" }
            #     result.failure { |failure| puts "Failed to finished closed auction: #{failure.errors.to_h}"}
            #   end
            def self.call(attributes, &block)
              operation = new.call(attributes)

              return operation unless block

              Dry::Matcher::ResultMatcher.call(operation, &block)
            end

            ##
            # Performs the closing of a closed auction.
            #
            # @param attributes [Hash] The attributes for the closed operation.
            # @option attributes auction_id [Integer] The ID of the auction.
            # @return [Dry::Monads::Result] The result of the operation.
            #
            # @example
            #   attributes = { auction_id: 123 }
            #
            #   operation = AuctionFunCore::Operations::AuctionContext::Processor::Finish::ClosedOperation.call(attributes)
            #
            #   if operation.success?
            #     auction = operation.success
            #     puts "Finished closed auction sucessfully! #{auction.to_h}"
            #   end
            #
            #   if operation.failure?
            #     failure = operation.failure
            #     puts "Failed to finished closed auction: #{failure.errors.to_h}"
            #   end
            def call(attributes)
              auction = yield validate_contract(attributes)
              summary = yield load_closed_auction_winners_and_participants(auction.id)
              update_auction_attributes = yield update_finished_auction(auction, summary)

              auction_repository.transaction do |_t|
                auction, _ = auction_repository.update(auction.id, update_auction_attributes)

                yield winner_operation(auction.id, summary.winner_id)

                summary.participant_ids.each do |participant_id|
                  yield participant_operation(auction.id, participant_id)
                end

                publish_auction_finish_event(auction)
              end

              Success(auction)
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
              contract = closed_contract.call(attributes)

              return Failure(contract.errors.to_h) if contract.failure?

              Success(contract.context[:auction])
            end

            ##
            # Loads the winners and participants of the closed auction.
            #
            # @param auction_id [Integer] The ID of the auction.
            # @return [Dry::Monads::Result] The result of loading the winners and participants.
            #
            def load_closed_auction_winners_and_participants(auction_id)
              summary = relation.load_closed_auction_winners_and_participants(auction_id).first

              Success(summary)
            end

            ##
            # Updates the attributes of the finished auction.
            #
            # @param auction [Auction] The auction object.
            # @param summary [Summary] The summary of winners and participants.
            # @return [Dry::Monads::Result] The result of updating the attributes.
            #
            def update_finished_auction(auction, summary)
              attrs = {status: "finished"}
              attrs[:winner_id] = summary.winner_id if summary.winner_id.present?

              Success(attrs)
            end

            ##
            # Retrieves the relation.
            #
            # @return [ROM::Relation] The relation object.
            #
            def relation
              AuctionFunCore::Application[:container].relations[:auctions]
            end

            ##
            # Executes the winner operation asynchronously.
            #
            # @param auction_id [Integer] The ID of the auction.
            # @param winner_id [Integer] The ID of the winner.
            # @return [Dry::Monads::Result] The result of executing the operation.
            #
            def winner_operation(auction_id, winner_id)
              return Success() if winner_id.blank?

              Success(winner_operation_job.class.perform_async(auction_id, winner_id))
            end

            ##
            # Executes the participant operation asynchronously.
            #
            # @param auction_id [Integer] The ID of the auction.
            # @param participant_id [Integer] The ID of the participant.
            # @return [Dry::Monads::Result] The result of executing the operation.
            #
            def participant_operation(auction_id, participant_id)
              Success(participant_operation_job.class.perform_async(auction_id, participant_id))
            end

            ##
            # Publishes the auction finish event.
            #
            # @param auction [ROM::Struct::Auction] The auction object.
            # @return [void]
            #
            def publish_auction_finish_event(auction)
              Application[:event].publish("auctions.finished", auction.to_h)
            end
          end
        end
      end
    end
  end
end
