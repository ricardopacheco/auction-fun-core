# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module StaffContext
      # This class is designed to authenticate staff members.
      # It validates the login and password, checking their format and verifying them against the database records.
      #
      # @example Authenticating a staff member
      #   contract = AuctionFunCore::Contracts::StaffContext::AuthenticationContract.new
      #   attributes = { login: 'staff@example.com', password: 'securePassword123' }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Authentication successful."
      #   else
      #     puts "Authentication failed: #{result.errors.to_h}"
      #   end
      #
      class AuthenticationContract < ApplicationContract
        # Scope for internationalization (i18n) entries specific to errors in this contract.
        I18N_SCOPE = "contracts.errors.custom.default"

        # Repositories initialized to retrieve data for validation.
        option :staff_repository, default: proc { Repos::StaffContext::StaffRepository.new }

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

        # Validates the presence of the staff member in the database and checks if the password matches.
        rule do |context:|
          next if (rule_error?(:login) || schema_error?(:login)) || (rule_error?(:password) || schema_error?(:password))

          context[:staff] ||= staff_repository.by_login(values[:login])

          next if context[:staff].present? && context[:staff].active? && (BCrypt::Password.new(context[:staff].password_digest) == values[:password])

          if context[:staff].blank? || (BCrypt::Password.new(context[:staff].password_digest) != values[:password])
            key(:base).failure(I18n.t("login_not_found", scope: I18N_SCOPE))
          end

          if context[:staff].present? && context[:staff].inactive?
            key(:base).failure(I18n.t("inactive_account", scope: I18N_SCOPE))
          end

          key(:base).failure(I18n.t("login_not_found", scope: I18N_SCOPE))
        end
      end
    end
  end
end
