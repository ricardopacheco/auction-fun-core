# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for auctions.
    # @see https://rom-rb.org/5.0/learn/sql/relations/
    class Auctions < ROM::Relation[:sql]
      use :pagination, per_page: 10

      KINDS = Types::Coercible::String.default("standard").enum("standard", "penny", "closed")
      STATUSES = Types::Coercible::String.default("scheduled")
        .enum("scheduled", "running", "paused", "canceled", "finished")

      schema(:auctions, infer: true) do
        attribute :id, Types::Integer
        attribute :staff_id, Types::ForeignKey(:staffs)
        attribute :title, Types::String
        attribute :description, Types::String
        attribute :kind, KINDS
        attribute :status, STATUSES
        attribute :started_at, Types::DateTime
        attribute :finished_at, Types::DateTime
        attribute :stopwatch, Types::Integer
        attribute :initial_bid_cents, Types::Integer
        attribute :initial_bid_currency, Types::String
        attribute :minimal_bid_cents, Types::Integer
        attribute :minimal_bid_currency, Types::String

        attribute :metadata, Types::PG::JSONB
        attribute :statistics, Types::PG::JSONB
        primary_key :id

        associations do
          belongs_to :staff, as: :staff, relation: :staffs
          has_many :bids, as: :bids, relation: :bids
        end
      end

      struct_namespace Entities
      auto_struct(true)
    end
  end
end
