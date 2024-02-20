# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module StaffContext
      # Contract class to authenticate staff.
      class AuthenticationContract < ApplicationContract
        I18N_SCOPE = "contracts.errors.custom.default"

        option :staff_repository, default: proc { Repos::StaffContext::StaffRepository.new }

        params do
          required(:login)
          required(:password)

          before(:value_coercer) do |result|
            result.to_h.compact
          end
        end

        rule(:login).validate(:login_format)
        rule(:password).validate(:password_format)

        # Validation for login.
        # Searches for the staff in the database from the login, and, if found,
        # compares the entered password.
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
