# frozen_string_literal: true

module AuctionFunCore
  module Operations
    module UserContext
      ##
      # Operation class for create new users.
      #
      class RegistrationOperation < AuctionFunCore::Operations::Base
        include Import["contracts.user_context.registration_contract"]
        include Import["repos.user_context.user_repository"]

        def self.call(attributes, &block)
          operation = new.call(attributes)

          return operation unless block

          Dry::Matcher::ResultMatcher.call(operation, &block)
        end

        # @todo Add custom doc
        def call(attributes)
          values = yield validate(attributes)
          values_with_encrypt_password = yield encrypt_password(values)

          user_repository.transaction do |_t|
            @user = yield persist(values_with_encrypt_password)

            yield publish_user_registration(@user.id)
          end

          Success(@user)
        end

        # Calls the user creation contract class to perform the validation
        # of the informed attributes.
        # @param attrs [Hash] user attributes
        # @return [Dry::Monads::Result::Success, Dry::Monads::Result::Failure]
        def validate(attrs)
          registration_contract.call(attrs).to_monad
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

          Success(
            Application[:event].publish("users.registration", user.info)
          )
        end
      end
    end
  end
end
