# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module StaffContext
      ##
      # Operation class for authenticate staff members.
      #
      class AuthenticationOperation < AuctionFunCore::Operations::Base
        include Import["contracts.staff_context.authentication_contract"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          staff = yield validate_contract(attributes)

          yield publish_staff_authentication(staff.id)

          Success(staff)
        end

        # Calls the authentication contract class to perform the validation
        # and authentication of the informed attributes.
        # @param attrs [Hash] Staff attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = authentication_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.context[:staff])
        end

        # Triggers the publication of event *staffs.registration*.
        # @param staff_id [Integer] Staff ID
        # @return [Dry::Monads::Result::Success]
        def publish_staff_authentication(staff_id, time = Time.current)
          Success(
            Application[:event].publish("staffs.authentication", {staff_id: staff_id, time: time})
          )
        end
      end
    end
  end
end
