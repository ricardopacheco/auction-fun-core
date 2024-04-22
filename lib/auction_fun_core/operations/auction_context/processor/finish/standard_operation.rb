# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module AuctionContext
      module Processor
        module Finish
          ##
          # Operation class for finalizing a standard auction.
          # By default, this change auction status from 'running' to 'finished'.
          #
          class StandardOperation < AuctionFunCore::Operations::Base
            include Import["repos.auction_context.auction_repository"]
            include Import["contracts.auction_context.processor.finish.standard_contract"]
            include Import["workers.operations.auction_context.post_auction.winner_operation_job"]
            include Import["workers.operations.auction_context.post_auction.participant_operation_job"]

            # @todo Add custom doc
            def self.call(attributes, &block)
              operation = new.call(attributes)

              return operation unless block

              Dry::Matcher::ResultMatcher.call(operation, &block)
            end

            # TODO: update doc
            # It only performs the basic processing of completing an auction.
            # It just changes the status at the database level and triggers the finished event.
            # @param attrs [Hash] auction attributes
            # @option auction_id [Integer] Auction ID
            # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
            def call(attributes)
              auction = yield validate_contract(attributes)
              summary = yield load_standard_auction_winners_and_participants(auction.id)
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

            # Calls the finish standard contract class to perform the validation
            # of the informed attributes.
            # @param attributes [Hash] auction attributes
            # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
            def validate_contract(attributes)
              contract = standard_contract.call(attributes)

              return Failure(contract.errors.to_h) if contract.failure?

              Success(contract.context[:auction])
            end

            def load_standard_auction_winners_and_participants(auction_id)
              summary = relation.load_standard_auction_winners_and_participants(auction_id).first

              Success(summary)
            end

            def update_finished_auction(auction, summary)
              attrs = {status: "finished"}
              attrs[:winner_id] = summary.winner_id if summary.winner_id.present?

              Success(attrs)
            end

            def relation
              AuctionFunCore::Application[:container].relations[:auctions]
            end

            def winner_operation(auction_id, winner_id)
              return Success() if winner_id.blank?

              Success(winner_operation_job.class.perform_async(auction_id, winner_id))
            end

            def participant_operation(auction_id, participant_id)
              Success(participant_operation_job.class.perform_async(auction_id, participant_id))
            end

            def publish_auction_finish_event(auction)
              Application[:event].publish("auctions.finished", auction.to_h)
            end
          end
        end
      end
    end
  end
end
