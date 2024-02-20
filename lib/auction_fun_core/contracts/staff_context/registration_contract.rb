# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module StaffContext
      # Contract class to create new staff.
      class RegistrationContract < ApplicationContract
        I18N_SCOPE = "contracts.errors.custom.default"

        option :staff_repository, default: proc { Repos::StaffContext::StaffRepository.new }

        # @param [Hash] opts Sets an allowed list of parameters, as well as some initial validations.
        params do
          required(:name)
          required(:email)
          required(:phone)

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
          if !rule_error?(:email) && staff_repository.exists?(email: value)
            key.failure(I18n.t(:taken, scope: I18N_SCOPE))
          end
        end

        # Validation for phone.
        # It must validate the format and uniqueness in the database.
        rule(:phone).validate(:phone_format)
        rule(:phone) do
          if !rule_error?(:phone) && staff_repository.exists?(phone: value)
            key.failure(I18n.t(:taken, scope: I18N_SCOPE))
          end
        end
      end
    end
  end
end
