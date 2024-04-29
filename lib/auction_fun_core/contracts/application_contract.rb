# frozen_string_literal: true

require "phonelib"

module AuctionFunCore
  module Contracts
    ##
    # The class includes several macros for common validation tasks, such as validating email format,
    # login format, name format, phone number format, and password format. These macros utilize
    # regular expressions and predefined length ranges to ensure the input data meets specific criteria.
    # @abstract
    class ApplicationContract < Dry::Validation::Contract
      include AuctionFunCore::Business::Configuration

      I18N_MACRO_SCOPE = "contracts.errors.custom.macro"
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

      config.messages.backend = :i18n
      config.messages.default_locale = I18n.default_locale
      config.messages.top_namespace = "contracts"
      config.messages.load_paths << Application.root.join("i18n/#{I18n.default_locale}/contracts/contracts.#{I18n.default_locale}.yml").to_s

      # Validates whether the provided value matches the standard email format.
      register_macro(:email_format) do
        next if EMAIL_REGEX.match?(value)

        key.failure(I18n.t(:email_format, scope: I18N_MACRO_SCOPE))
      end

      # Validates whether the provided value matches either the email format or a valid phone number format using Phonelib.
      register_macro(:login_format) do
        next if EMAIL_REGEX.match?(value) || Phonelib.parse(value).valid?

        key.failure(I18n.t(:login_format, scope: I18N_MACRO_SCOPE))
      end

      # Validates whether the length of the provided name falls within the specified range.
      register_macro(:name_format) do
        next if value.length.between?(MIN_NAME_LENGTH, MAX_NAME_LENGTH)

        key.failure(
          I18n.t(:name_format, scope: I18N_MACRO_SCOPE, min: MIN_NAME_LENGTH, max: MAX_NAME_LENGTH)
        )
      end

      # Validates whether the provided value matches a valid phone number format using Phonelib.
      register_macro(:phone_format) do
        next if ::Phonelib.parse(value).valid?

        key.failure(I18n.t(:phone_format, scope: I18N_MACRO_SCOPE))
      end

      # Validates whether the length of the provided password falls within the specified range.
      register_macro(:password_format) do
        next if value.length.between?(MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH)

        key.failure(
          I18n.t(:password_format, scope: I18N_MACRO_SCOPE, min: MIN_PASSWORD_LENGTH, max: MAX_PASSWORD_LENGTH)
        )
      end
    end
  end
end
