# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module UserContext
      ##
      # Operation class for confirm users by token via email.
      #
      class EmailConfirmationOperation < AuctionFunCore::Operations::Base
        include Import["repos.user_context.user_repository"]
        include Import["contracts.user_context.email_confirmation_contract"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          user = yield validate_contract(attributes)

          user_repository.transaction do |_t|
            user = yield persist(user.id)

            yield publish_user_confirmation(user.id, user.confirmed_at)
          end

          Success(user)
        end

        # Calls the authentication contract class to perform the validation
        # and authentication of the informed attributes.
        # @param attrs [Hash] user attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = email_confirmation_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.context[:user])
        end

        # Calls the user repository class to update database fields.
        # @param user_id [Integer] User ID
        # @param time [Time] Confirmation time
        # @return [ROM::Struct::User]
        def persist(user_id, time = Time.current)
          result = {email_confirmation_token: nil, email_confirmed_at: time, confirmed_at: time}

          Success(user_repository.update(user_id, result))
        end

        # Triggers the publication of event *users.registration*.
        # @param user_id [Integer] User ID
        # @return [Dry::Monads::Result::Success]
        def publish_user_confirmation(user_id, time = Time.current)
          Success(
            Application[:event].publish("users.confirmation", {user_id: user_id, time: time})
          )
        end
      end
    end
  end
end
