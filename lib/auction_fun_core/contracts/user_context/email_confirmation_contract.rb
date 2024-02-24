# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # Contract class responsible for validating the confirmation token for email.
      class EmailConfirmationContract < ApplicationContract
        I18N_SCOPE = "contracts.errors.custom.default"

        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

        params do
          required(:email_confirmation_token)

          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        # Validation for email_confirmation_token.
        # Searches for the user in the database from the email_confirmation_token
        rule do |context:|
          next if schema_error?(:email_confirmation_token)

          context[:user] ||= user_repository.by_email_confirmation_token(values[:email_confirmation_token])

          next if context[:user].present?

          key(:email_confirmation_token).failure(I18n.t("not_found", scope: I18N_SCOPE))
        end

        rule do |context:|
          next if context[:user].blank? || context[:user].active?

          key(:base).failure(I18n.t("inactive_account", scope: I18N_SCOPE))
        end
      end
    end
  end
end
