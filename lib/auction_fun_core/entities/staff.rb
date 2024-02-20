# frozen_string_literal: true

module AuctionFunCore
  module Entities
    # Staff Relations class. This return simple objects with attribute readers
    # to represent data in your staff.
    class Staff < ROM::Struct
      def info
        attributes.except(:password_digest)
      end
    end
  end
end
