# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for bids
    # @see https://rom-rb.org/5.2/learn/sql/relations/
    class Bids < ROM::Relation[:sql]
      use :pagination, per_page: 3

      schema(:bids, infer: true) do
        attribute :id, Types::Integer

        attribute :auction_id, Types::ForeignKey(:auctions)
        attribute :user_id, Types::ForeignKey(:users)

        associations do
          belongs_to :auction
          belongs_to :user
        end

        primary_key :id
      end

      struct_namespace Entities
      auto_struct(true)
    end
  end
end
