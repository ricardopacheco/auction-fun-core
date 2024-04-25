# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for bids
    # @see https://rom-rb.org/5.0/learn/sql/relations/
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

      # Retrieves a list of unique user IDs who have placed bids in a specified auction.
      # A participant in an auction is defined as a user who has placed one or more bids.
      #
      # @param auction_id [Integer] the ID of the auction.
      # @return [Array<Integer>] Returns an array of unique user IDs who have participated in the auction.
      # @raise [RuntimeError] Raises an error if the auction_id is not an integer.
      def participants(auction_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer)

        sql = <<-SQL
          SELECT COALESCE(ARRAY_AGG(DISTINCT user_id), ARRAY[]::INT[]) AS participant_ids
          FROM bids
          WHERE auction_id = #{auction_id}
        SQL

        read(sql)
      end
    end
  end
end
