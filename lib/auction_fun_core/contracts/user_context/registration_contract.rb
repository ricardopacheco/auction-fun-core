# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # Contract class to create new users.
      class RegistrationContract < ApplicationContract
        I18N_SCOPE = "contracts.errors.custom.default"

        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

        # @param [Hash] opts Sets an allowed list of parameters, as well as some initial validations.
        params do
          required(:name)
          required(:email)
          required(:phone)
          required(:password)
          required(:password_confirmation)

          before(:value_coercer) do |result|
            result.to_h.compact
          end

          # Normalize and add default values
          after(:value_coercer) do |result|
            result.update(email: result[:email].strip.downcase) if result[:email]
            result.update(phone: result[:phone].tr_s("^0-9", "")) if result[:phone]
          end
        end

        rule(:name).validate(:name_format)

        # Validation for email.
        # It must validate the format and uniqueness in the database.
        rule(:email).validate(:email_format)
        rule(:email) do
          # Email should be unique on database
          if !rule_error?(:email) && user_repository.exists?(email: value)
            key.failure(I18n.t(:taken, scope: I18N_SCOPE))
          end
        end

        # Validation for phone.
        # It must validate the format and uniqueness in the database.
        rule(:phone).validate(:phone_format)
        rule(:phone) do
          if !rule_error?(:phone) && user_repository.exists?(phone: value)
            key.failure(I18n.t(:taken, scope: I18N_SCOPE))
          end
        end

        # Validation for password.
        # Check if the confirmation matches the password.
        rule(:password).validate(:password_format)
        rule(:password, :password_confirmation) do
          if !rule_error?(:password) && values[:password] != values[:password_confirmation]
            key(:password_confirmation).failure(I18n.t(:password_confirmation, scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
