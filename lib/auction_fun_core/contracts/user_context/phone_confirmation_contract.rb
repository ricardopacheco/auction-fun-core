# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # This class provides validation for confirming phone numbers.
      # It verifies the provided phone confirmation token against stored user data in the system.
      #
      # @example Confirming a phone number
      #   contract = AuctionFunCore::Contracts::UserContext::PhoneConfirmationContract.new
      #   attributes = { phone_confirmation_token: 'example_token' }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Phone number enabled for confirmation."
      #   else
      #     puts "Failed to confirm phone number: #{result.errors.to_h}"
      #   end
      #
      class PhoneConfirmationContract < ApplicationContract
        # Scope for internationalization (i18n) entries specific to errors in this contract.
        I18N_SCOPE = "contracts.errors.custom.default"

        # Repositories initialized to retrieve data for validation.
        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:phone_confirmation_token)

          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Searches for the user in the database from the phone_confirmation_token
        rule do |context:|
          next if schema_error?(:phone_confirmation_token)

          context[:user] ||= user_repository.by_phone_confirmation_token(values[:phone_confirmation_token])

          next if context[:user].present?

          key(:phone_confirmation_token).failure(I18n.t("not_found", scope: I18N_SCOPE))
        end

        # Additional validation to check if the user account associated with the token is active.
        rule do |context:|
          next if context[:user].blank? || context[:user].active?

          key(:base).failure(I18n.t("inactive_account", scope: I18N_SCOPE))
        end
      end
    end
  end
end
