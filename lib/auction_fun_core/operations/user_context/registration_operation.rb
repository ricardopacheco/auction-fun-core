# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module UserContext
      ##
      # Operation class for create new users.
      #
      class RegistrationOperation < AuctionFunCore::Operations::Base
        include Import["repos.user_context.user_repository"]
        include Import["contracts.user_context.registration_contract"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          values = yield validate_contract(attributes)
          values_with_encrypt_password = yield encrypt_password(values)

          user_repository.transaction do |_t|
            @user = yield persist(values_with_encrypt_password)

            yield publish_user_registration(@user.id)
            yield send_welcome_email(@user.id)
          end

          Success(@user)
        end

        # Calls registration contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] user attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate_contract(attrs)
          contract = registration_contract.call(attrs)

          return Failure(contract.errors.to_h) if contract.failure?

          Success(contract.to_h)
        end

        # Transforms the password attribute, encrypting it to be saved in the database.
        # @param result [Hash] User valid contract attributes
        # @return [Hash] Valid user database
        def encrypt_password(attrs)
          attributes = attrs.to_h.except(:password)

          Success(
            {**attributes, password_digest: BCrypt::Password.create(attrs[:password])}
          )
        end

        # Calls the user repository class to persist the attributes in the database.
        # @param result [Hash] User validated attributes
        # @return [ROM::Struct::User]
        def persist(result)
          Success(user_repository.create(result))
        end

        # Triggers the publication of event *users.registration*.
        # @param user_id [Integer] User ID
        # @return [Dry::Monads::Result::Success]
        def publish_user_registration(user_id)
          user = user_repository.by_id!(user_id)

          Success(Application[:event].publish("users.registration", user.info))
        end

        # Schedule the asynchronous sending of a welcome email.
        # @param user_id [Integer] User ID
        # @return [Dry::Monads::Result::Success]
        def send_welcome_email(user_id)
          Success(registration_mailer_job.perform_async(user_id))
        end

        private

        # Since the shipping code structure does not follow project conventions,
        # making the default injection dependency would be more complicated.
        # Therefore, here I directly explain the class to be called.
        def registration_mailer_job
          AuctionFunCore::Workers::Services::Mail::UserContext::RegistrationMailerJob
        end
      end
    end
  end
end
