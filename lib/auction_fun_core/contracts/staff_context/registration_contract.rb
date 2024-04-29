# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module StaffContext
      # This class is designed to create staff members.
      # It validates the parameters, ensuring their format and uniqueness.
      #
      # @example Registering a new staff member
      #   contract = AuctionFunCore::Contracts::StaffContext::RegistrationContract.new
      #   attributes = { name: 'John Doe', email: 'john.doe@example.com', phone: '1234567890' }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Staff member registered successfully."
      #   else
      #     puts "Failed to register staff member: #{result.errors.to_h}"
      #   end
      #
      class RegistrationContract < ApplicationContract
        # Scope for internationalization (i18n) entries specific to errors in this contract.
        I18N_SCOPE = "contracts.errors.custom.default"

        # Repositories initialized to retrieve data for validation.
        option :staff_repository, default: proc { Repos::StaffContext::StaffRepository.new }

        # Parameters specifying the required input types and fields.
        params do
          required(:name)
          required(:email)
          required(:phone)

          before(:value_coercer) do |result|
            result.to_h.compact
          end

          # Normalizes and adds default values after coercion.
          after(:value_coercer) do |result|
            result.update(email: result[:email].strip.downcase) if result[:email]
            result.update(phone: result[:phone].tr_s("^0-9", "")) if result[:phone]
          end
        end

        # Validates the format of the staff member's name.
        rule(:name).validate(:name_format)

        # It ensures email format and checks for uniqueness in the database.
        rule(:email).validate(:email_format)
        rule(:email) do
          if !rule_error?(:email) && staff_repository.exists?(email: value)
            key.failure(I18n.t(:taken, scope: I18N_SCOPE))
          end
        end

        # It ensures phone format and checks for uniqueness in the database.
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
