# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # This class is designed to authenticate users.
      # It verifies the provided login credentials against stored user data in the system.
      #
      # @example Authenticating a user
      #   contract = AuctionFunCore::Contracts::UserContext::AuthenticationContract.new
      #   attributes = { login: 'example_user', password: 'securePassword123' }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "User authenticated successfully."
      #   else
      #     puts "Authentication failed: #{result.errors.to_h}"
      #   end
      #
      class AuthenticationContract < ApplicationContract
        # Scope for internationalization (i18n) entries specific to errors in this contract.
        I18N_SCOPE = "contracts.errors.custom.default"

        # Repositories initialized to retrieve data for validation.
        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:login)
          required(:password)

          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Additional rules for validating the format of login and password.
        rule(:login).validate(:login_format)
        rule(:password).validate(:password_format)

        # Validates the presence of the user in the database and checks if the password matches.
        rule do |context:|
          next if (rule_error?(:login) || schema_error?(:login)) || (rule_error?(:password) || schema_error?(:password))

          context[:user] ||= user_repository.by_login(values[:login])

          next if context[:user].present? && context[:user].active? && (BCrypt::Password.new(context[:user].password_digest) == values[:password])

          if context[:user].blank? || (BCrypt::Password.new(context[:user].password_digest) != values[:password])
            key(:base).failure(I18n.t("login_not_found", scope: I18N_SCOPE))
          end

          if context[:user].present? && context[:user].inactive?
            key(:base).failure(I18n.t("inactive_account", scope: I18N_SCOPE))
          end

          key(:base).failure(I18n.t("login_not_found", scope: I18N_SCOPE))
        end
      end
    end
  end
end
