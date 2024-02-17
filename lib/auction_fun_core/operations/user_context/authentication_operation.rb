# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module UserContext
      ##
      # Operation class for authenticate users.
      #
      class AuthenticationOperation < AuctionFunCore::Operations::Base
        include Import["contracts.user_context.authentication_contract"]
        # include Import["repos.user_context.user_repository"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          user = yield validate_contract(attributes)

          yield publish_user_authentication(user.id)

          Success(user)
        end

        # Calls the authentication contract class to perform the validation
        # and authentication of the informed attributes.
        # @param attrs [Hash] user attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = authentication_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.context[:user])
        end

        # Triggers the publication of event *users.registration*.
        # @param user_id [Integer] User ID
        # @return [Dry::Monads::Result::Success]
        def publish_user_authentication(user_id, time = Time.current)
          Success(
            Application[:event].publish("users.authentication", {user_id: user_id, time: time})
          )
        end
      end
    end
  end
end
