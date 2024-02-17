# frozen_string_literal: true

require "phonelib"

module AuctionFunCore
  module Contracts
    # Abstract base class for contracts.
    # @abstract
    class ApplicationContract < Dry::Validation::Contract
      I18N_MACRO_SCOPE = "contracts.errors.custom.macro"
      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
      MIN_NAME_LENGTH = 6
      MAX_NAME_LENGTH = 128
      MIN_PASSWORD_LENGTH = 6
      MAX_PASSWORD_LENGTH = 128

      config.messages.backend = :i18n
      config.messages.default_locale = I18n.default_locale
      config.messages.top_namespace = "contracts"
      config.messages.load_paths << Application.root.join("config/locales/contracts/#{I18n.default_locale}.yml").to_s

      register_macro(:email_format) do
        next if EMAIL_REGEX.match?(value)

        key.failure(I18n.t(:email_format, scope: I18N_MACRO_SCOPE))
      end

      register_macro(:name_format) do
        next if value.length.between?(MIN_NAME_LENGTH, MAX_NAME_LENGTH)

        key.failure(
          I18n.t(:name_format, scope: I18N_MACRO_SCOPE, min: MIN_NAME_LENGTH, max: MAX_NAME_LENGTH)
        )
      end

      register_macro(:phone_format) do
        next if ::Phonelib.parse(value).valid?

        key.failure(I18n.t(:phone_format, scope: I18N_MACRO_SCOPE))
      end

      register_macro(:password_format) do
        next if value.length.between?(MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH)

        key.failure(
          I18n.t(:password_format, scope: I18N_MACRO_SCOPE, min: MIN_PASSWORD_LENGTH, max: MAX_PASSWORD_LENGTH)
        )
      end
    end
  end
end
