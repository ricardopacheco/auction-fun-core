# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module StaffContext
      ##
      # Operation class for create new staff member.
      #
      class RegistrationOperation < AuctionFunCore::Operations::Base
        include Import["contracts.staff_context.registration_contract"]
        include Import["repos.staff_context.staff_repository"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          values = yield validate_contract(attributes)
          values_with_encrypt_password = yield encrypt_password(values)

          staff_repository.transaction do |_t|
            @staff = yield persist(values_with_encrypt_password)

            yield publish_staff_registration(@staff.id)
          end

          Success(@staff)
        end

        # Calls registration contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] staff attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = registration_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.to_h)
        end

        # Transforms the password attribute, encrypting it to be saved in the database.
        # @param result [Hash] Staff valid contract attributes
        # @return [Hash] Valid staff database
        def encrypt_password(attrs)
          attributes = attrs.to_h.except(:password)

          Success(
            {**attributes, password_digest: BCrypt::Password.create(attrs[:password])}
          )
        end

        # Calls the staff repository class to persist the attributes in the database.
        # @param result [Hash] Staff validated attributes
        # @return [ROM::Struct::Staff]
        def persist(result)
          Success(staff_repository.create(result))
        end

        # Triggers the publication of event *staffs.registration*.
        # @param staff_id [Integer] Staff ID
        # @return [Dry::Monads::Result::Success]
        def publish_staff_registration(staff_id)
          staff = staff_repository.by_id!(staff_id)

          Success(Application[:event].publish("staffs.registration", staff.info))
        end
      end
    end
  end
end
