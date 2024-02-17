# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module UserContext
      # Contract class to authenticate users.
      class AuthenticationContract < ApplicationContract
        I18N_SCOPE = "contracts.errors.custom.default"

        option :user_repository, default: proc { Repos::UserContext::UserRepository.new }

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
        # Must to be present and format should be a email or phone.
        rule do |context:|
          next if (rule_error?(:login) || schema_error?(:login)) || (rule_error?(:password) || schema_error?(:password))

          context[:user] ||= user_repository.by_login(values[:login])
          next if context[:user].present? && valid_password?(values[:password], context[:user].password_digest)

          key(:base).failure(I18n.t("login_not_found", scope: I18N_SCOPE))
        end

        private

        def valid_password?(password, password_digest)
          return false if password_digest.blank?

          BCrypt::Password.new(password_digest) == password
        end
      end
    end
  end
end
