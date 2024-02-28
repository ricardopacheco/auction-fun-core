# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for users.
    # @see https://rom-rb.org/5.0/learn/sql/relations/
    class Users < ROM::Relation[:sql]
      use :pagination, per_page: 10

      schema(:users, infer: true) do
        attribute :id, Types::Integer
        attribute :name, Types::String
        attribute :email, Types::String
        attribute :phone, Types::String
        attribute :active, Types::Bool
        attribute :balance_cents, Types::Integer
        attribute :balance_currency, Types::String

        primary_key :id
      end

      struct_namespace Entities
      auto_struct(true)
    end
  end
end
