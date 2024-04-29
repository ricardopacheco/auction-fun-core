# frozen_string_literal: true

module AuctionFunCore
  module Relations
    # SQL relation for auctions.
    # @see https://rom-rb.org/5.0/learn/sql/relations/
    class Auctions < ROM::Relation[:sql]
      use :pagination, per_page: 10

      KINDS = Types::Coercible::String.enum("standard", "penny", "closed")
      STATUSES = Types::Coercible::String.enum("scheduled", "running", "paused", "canceled", "finished")

      schema(:auctions, infer: true) do
        attribute :id, Types::Integer
        attribute :staff_id, Types::ForeignKey(:staffs)
        attribute :winner_id, Types::ForeignKey(:users)
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
          belongs_to :winner, as: :winner, relation: :users, foreign_key: :winner_id
          has_many :bids, as: :bids, relation: :bids
        end
      end

      struct_namespace Entities
      auto_struct(true)

      # Retrieves a paginated list of auctions along with related information.
      # By default, it retrieves the first page with 10 auctions per page and includes information for the top 3 bidders.
      #
      # @param page [Integer] The page number to retrieve (default is 1).
      # @param per_page [Integer] The number of auctions per page (default is 10).
      # @param options [Hash] Additional options for customization (default is {bidders_count: 3}).
      # @option options [Integer] :bidders_count The number of top bidders to include in the result (default is 3).
      # @return [Array<Hash>] An array of hashes representing the auctions and related information.
      # @example Retrieve the first page of auctions with 10 per page and include information for the top 3 bidders
      #   all_auctions = all
      #
      # @example Retrieve the second page of auctions with 5 per page and include information for the top 5 bidders
      #   all_auctions = all(2, 5, { bidders_count: 5 })
      #
      # @example Retrieve the third page of auctions with 15 per page and include information for the top 2 bidders
      #   all_auctions = all(3, 15, { bidders_count: 2 })
      #
      # @raise [RuntimeError] if either `page` or `per_page` argument is not an integer.
      def all(page = 1, per_page = 10, options = {bidders_count: 3})
        raise "Invalid argument" unless page.is_a?(Integer) && per_page.is_a?(Integer)

        offset = ((page - 1) * per_page)

        sql = <<-SQL
          SELECT a.id, a.title, a.description, a.kind, a.status, a.started_at, a.finished_at, a.stopwatch, a.initial_bid_cents,
          (SELECT COUNT(*) FROM (SELECT * FROM bids WHERE bids.auction_id = a.id) dt) AS total_bids,
          CASE
          WHEN a.kind = 'standard' THEN
            json_build_object(
              'current', a.minimal_bid_cents,
              'minimal', a.minimal_bid_cents,
              'bidders', COALESCE(
                json_agg(json_build_object('id', bi.id, 'user_id', users.id, 'name', users.name, 'value', bi.value_cents, 'date', bi.created_at) ORDER BY value_cents DESC)
                FILTER (where bi.id IS NOT NULL AND users.id IS NOT NULL), '[]'::json
              )
            )
          WHEN a.kind = 'penny' THEN
            json_build_object(
              'value', a.initial_bid_cents,
              'bidders', COALESCE(
                json_agg(json_build_object('id', bi.id, 'user_id', users.id, 'name', users.name, 'value', bi.value_cents, 'date', bi.created_at) ORDER BY value_cents DESC)
                FILTER (where bi.id IS NOT NULL AND users.id IS NOT NULL), '[]'::json
              )
            )
          WHEN a.kind = 'closed' THEN
            json_build_object('minimal', (a.initial_bid_cents + (a.initial_bid_cents * 0.10))::int)
          END as bids
          FROM auctions as a
          LEFT JOIN LATERAL (SELECT * FROM bids WHERE auction_id = a.id ORDER BY value_cents DESC LIMIT #{options[:bidders_count]}) as bi ON a.id = bi.auction_id
          LEFT JOIN users ON bi.user_id = users.id AND bi.auction_id = a.id
          GROUP BY a.id
          LIMIT #{per_page} OFFSET #{offset}
        SQL

        read(sql)
      end

      # Retrieves detailed information about a specific auction.
      #
      # @param auction_id [Integer] The ID of the auction to retrieve information for.
      # @param options [Hash] Additional options for customization (default is {bidders_count: 3}).
      # @option options [Integer] :bidders_count The number of top bidders to include in the result (default is 3).
      # @return [Hash] A hash representing the auction and related information.
      #
      # @example Retrieve information for auction with ID 123
      #   auction_info = info(123)
      #
      # @example Retrieve information for auction with ID 456 and include information for the top 5 bidders
      #   auction_info = info(456, { bidders_count: 5 })
      #
      # @example Retrieve information for auction with ID 789 and include information for the top 2 bidders
      #   auction_info = info(789, { bidders_count: 2 })
      #
      # @raise [RuntimeError] if `auction_id` argument is not an integer.
      def info(auction_id, options = {bidders_count: 3})
        raise "Invalid argument" unless auction_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, a.title, a.description, a.kind, a.status, a.started_at, a.finished_at, a.stopwatch, a.initial_bid_cents,
          (SELECT COUNT(*) FROM (SELECT * FROM bids WHERE bids.auction_id = #{auction_id}) dt) AS total_bids,
          CASE
          WHEN a.kind = 'standard' THEN
            json_build_object(
              'current', a.minimal_bid_cents,
              'minimal', a.minimal_bid_cents,
              'bidders', COALESCE(
                json_agg(json_build_object('id', bi.id, 'user_id', users.id, 'name', users.name, 'value', bi.value_cents, 'date', bi.created_at) ORDER BY value_cents DESC)
                FILTER (where bi.id IS NOT NULL AND users.id IS NOT NULL), '[]'::json
              )
            )
          WHEN a.kind = 'penny' THEN
            json_build_object(
              'value', a.initial_bid_cents,
              'bidders', COALESCE(
                json_agg(json_build_object('id', bi.id, 'user_id', users.id, 'name', users.name, 'value', bi.value_cents, 'date', bi.created_at) ORDER BY value_cents DESC)
                FILTER (where bi.id IS NOT NULL AND users.id IS NOT NULL), '[]'::json
              )
            )
          WHEN a.kind = 'closed' THEN
            json_build_object('minimal', (a.initial_bid_cents + (a.initial_bid_cents * 0.10))::int)
          END as bids
          FROM auctions as a
          LEFT JOIN LATERAL (SELECT * FROM bids WHERE auction_id = a.id ORDER BY value_cents DESC LIMIT #{options[:bidders_count]}) as bi ON a.id = bi.auction_id AND a.id = #{auction_id}
          LEFT JOIN users ON bi.user_id = users.id AND bi.auction_id = a.id
          WHERE a.id = #{auction_id}
          GROUP BY a.id
        SQL

        read(sql)
      end

      # Retrieves the standard auction winner and other participating bidders for a specified auction.
      #
      # This method queries the database to fetch the winner based on the highest bid and collects an array
      # of other participants who placed bids in the auction, all except for the winner. The method returns
      # structured data that includes the auction ID, winner's ID, total number of bids,
      # and a list of participant IDs.
      #
      # @return [Hash] a hash containing details about the auction, including winner and participants:
      #   - :id [Integer] the ID of the auction
      #   - :winner_id [Integer] the ID of the winning bidder
      #   - :total_bids [Integer] the total number of bids placed in the auction
      #   - :participants [Array<Integer>] an array of user IDs of the other participants, excluding the winner
      def load_standard_auction_winners_and_participants(auction_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, a.kind, a.status, w.user_id AS winner_id, COALESCE(COUNT(b.id), 0) AS total_bids,
            COALESCE(
              ARRAY_REMOVE(ARRAY_AGG(DISTINCT b.user_id ORDER BY b.user_id), w.user_id), ARRAY[]::INT[]
            ) AS participant_ids
          FROM auctions a
          LEFT JOIN bids b ON a.id = b.auction_id
          LEFT JOIN (
            SELECT auction_id, user_id, MAX(value_cents) AS value_cents
            FROM bids
            WHERE auction_id = #{auction_id}
            GROUP BY auction_id, user_id
            ORDER BY value_cents DESC
            LIMIT 1
          ) AS w ON a.id = w.auction_id
          WHERE a.id = #{auction_id}
          GROUP BY a.id, w.user_id
        SQL

        read(sql)
      end

      # Retrieves the penny auction winner and other participating bidders for a specified auction.
      #
      # This method queries the database to fetch the winner based on the latest bid and collects an array
      # of other participants who placed bids in the auction, all except for the winner. The method returns
      # structured data that includes the auction ID, winner's ID, total number of bids,
      # and a list of participant IDs.
      #
      # @return [Hash] a hash containing details about the auction, including winner and participants:
      #   - :id [Integer] the ID of the auction
      #   - :winner_id [Integer] the ID of the winning bidder
      #   - :total_bids [Integer] the total number of bids placed in the auction
      #   - :participants [Array<Integer>] an array of user IDs of the other participants, excluding the winner
      def load_penny_auction_winners_and_participants(auction_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, a.kind, a.status, w.user_id AS winner_id, COALESCE(COUNT(b.id), 0) AS total_bids,
            COALESCE(
              ARRAY_REMOVE(ARRAY_AGG(DISTINCT b.user_id ORDER BY b.user_id), w.user_id), ARRAY[]::INT[]
            ) AS participant_ids
          FROM auctions a
          LEFT JOIN bids b ON a.id = b.auction_id
          LEFT JOIN (
            SELECT auction_id, user_id
            FROM bids
            WHERE auction_id = #{auction_id}
            ORDER BY bids.created_at DESC
            LIMIT 1
          ) AS w ON a.id = w.auction_id
          WHERE a.id = #{auction_id}
          GROUP BY a.id, w.user_id
        SQL

        read(sql)
      end

      # Retrieves the closed auction winner and other participating bidders for a specified auction.
      #
      # This method queries the database to fetch the winner based on the highest bid and collects an array
      # of other participants who placed bids in the auction, all except for the winner. The method returns
      # structured data that includes the auction ID, winner's ID, total number of bids,
      # and a list of participant IDs.
      #
      # @return [Hash] a hash containing details about the auction, including winner and participants:
      #   - :id [Integer] the ID of the auction
      #   - :winner_id [Integer] the ID of the winning bidder
      #   - :total_bids [Integer] the total number of bids placed in the auction
      #   - :participants [Array<Integer>] an array of user IDs of the other participants, excluding the winner
      def load_closed_auction_winners_and_participants(auction_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, a.kind, a.status, w.user_id AS winner_id, COALESCE(COUNT(b.id), 0) AS total_bids,
            COALESCE(
              ARRAY_REMOVE(ARRAY_AGG(DISTINCT b.user_id ORDER BY b.user_id), w.user_id), ARRAY[]::INT[]
            ) AS participant_ids
          FROM auctions a
          LEFT JOIN bids b ON a.id = b.auction_id
          LEFT JOIN (
            SELECT auction_id, user_id, MAX(value_cents) AS value_cents
            FROM bids
            WHERE auction_id = #{auction_id}
            GROUP BY auction_id, user_id
            ORDER BY value_cents DESC
            LIMIT 1
          ) AS w ON a.id = w.auction_id
          WHERE a.id = #{auction_id}
          GROUP BY a.id, w.user_id
        SQL

        read(sql)
      end

      # Loads statistics for the winner of a specific auction.
      #
      # @param auction_id [Integer] The ID of the auction to load statistics for.
      # @param winner_id [Integer] The ID of the winner to load statistics for.
      # @return [Hash] A hash representing the statistics for the winner of the auction.
      #
      # @example Load statistics for the winner of auction with ID 123 and winner with ID 456
      #   winner_stats = load_winner_statistics(123, 456)
      #
      # @raise [RuntimeError] if either `auction_id` or `winner_id` arguments are not integers.
      def load_winner_statistics(auction_id, winner_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer) && winner_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, COUNT(b.id) AS auction_total_bids, MAX(b.value_cents) AS winner_bid,
            date(a.finished_at) as auction_date,
            (SELECT COUNT(*) FROM bids b2
              WHERE b2.auction_id = #{auction_id}
              AND b2.user_id = #{winner_id}
            ) AS winner_total_bids
          FROM auctions a
          LEFT JOIN bids b ON a.id = b.auction_id AND a.id = #{auction_id}
          LEFT JOIN users u ON u.id = b.user_id AND u.id = #{winner_id}
          LEFT JOIN (
            SELECT auction_id, user_id, MAX(value_cents) AS value_cents
            FROM bids
            WHERE auction_id = #{auction_id}
            GROUP BY auction_id, user_id
            ORDER BY value_cents DESC
            LIMIT 1
          ) AS w ON a.id = w.auction_id
          WHERE a.id = #{auction_id}
          GROUP BY a.id
        SQL

        read(sql)
      end

      # Loads statistics for a participant in a specific auction.
      #
      # @param auction_id [Integer] The ID of the auction to load statistics for.
      # @param participant_id [Integer] The ID of the participant to load statistics for.
      # @return [Hash] A hash representing the statistics for the participant in the auction.
      #
      # @example Load statistics for the participant with ID 456 in auction with ID 123
      #   participant_stats = load_participant_statistics(123, 456)
      #
      # @raise [RuntimeError] if either `auction_id` or `participant_id` arguments are not integers.
      def load_participant_statistics(auction_id, participant_id)
        raise "Invalid argument" unless auction_id.is_a?(Integer) && participant_id.is_a?(Integer)

        sql = <<-SQL
          SELECT a.id, COUNT(b.id) AS auction_total_bids, MAX(b.value_cents) AS winner_bid,
            date(a.finished_at) as auction_date,
            (SELECT COUNT(*) FROM bids b2
              WHERE b2.auction_id = #{auction_id}
              AND b2.user_id = #{participant_id}
            ) AS winner_total_bids
          FROM auctions a
          LEFT JOIN bids b ON a.id = b.auction_id AND a.id = #{auction_id}
          LEFT JOIN users u ON u.id = b.user_id AND u.id = #{participant_id}
          LEFT JOIN (
            SELECT auction_id, user_id, MAX(value_cents) AS value_cents
            FROM bids
            WHERE auction_id = #{auction_id}
            GROUP BY auction_id, user_id
            ORDER BY value_cents DESC
            LIMIT 1
          ) AS w ON a.id = w.auction_id
          WHERE a.id = #{auction_id}
          GROUP BY a.id
        SQL

        read(sql)
      end
    end
  end
end
