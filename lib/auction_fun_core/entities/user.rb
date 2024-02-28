# frozen_string_literal: true

module AuctionFunCore
  module Entities
    # User Relations class. This return simple objects with attribute readers
    # to represent data in your user.
    class User < ROM::Struct
      def active?
        active
      end

      def inactive?
        !active
      end

      def confirmed?
        confirmed_at.present?
      end

      def email_confirmed?
        email_confirmation_at.present?
      end

      def phone_confirmed?
        phone_confirmation_at.present?
      end

      def info
        attributes.except(:password_digest)
      end

      def balance
        Money.new(balance_cents, balance_currency)
      end
    end
  end
end
