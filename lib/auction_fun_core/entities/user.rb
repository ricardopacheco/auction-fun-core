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

      def info
        attributes.except(:password_digest)
      end
    end
  end
end
