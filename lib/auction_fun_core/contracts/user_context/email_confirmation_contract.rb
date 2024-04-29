# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # This class provides validation for confirming email addresses.
      # It verifies the provided email confirmation token against stored user data in the system.
      #
      # @example Confirming an email address
      #   contract = AuctionFunCore::Contracts::UserContext::EmailConfirmationContract.new
      #   attributes = { email_confirmation_token: 'example_token' }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Email address enabled for confirmation."
      #   else
      #     puts "Failed to confirm email address: #{result.errors.to_h}"
      #   end
      #
      class EmailConfirmationContract < ApplicationContract
        # Scope for internationalization (i18n) entries specific to errors in this contract.
        I18N_SCOPE = "contracts.errors.custom.default"

        # Repositories initialized to retrieve data for validation.
        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:email_confirmation_token)

          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Searches for the user in the database from the email_confirmation_token
        rule do |context:|
          next if schema_error?(:email_confirmation_token)

          context[:user] ||= user_repository.by_email_confirmation_token(values[:email_confirmation_token])

          next if context[:user].present?

          key(:email_confirmation_token).failure(I18n.t("not_found", scope: I18N_SCOPE))
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
