# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for staffs.
    # @see https://rom-rb.org/5.0/learn/sql/relations/
    class Staffs < ROM::Relation[:sql]
      use :pagination, per_page: 10

      STAFF_KINDS = Types::Coercible::String.default("common").enum("root", "common")

      schema(:staffs, infer: true) do
        attribute :id, Types::Integer
        attribute :name, Types::String
        attribute :email, Types::String
        attribute :phone, Types::String
        attribute :kind, STAFF_KINDS
        attribute :active, Types::Bool

        primary_key :id
      end

      struct_namespace Entities
      auto_struct(true)
    end
  end
end
