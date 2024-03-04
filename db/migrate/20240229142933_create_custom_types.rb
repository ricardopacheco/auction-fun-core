# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run "CREATE TYPE auction_kinds AS ENUM('standard', 'penny', 'closed')"
    run "CREATE TYPE auction_statuses AS ENUM('scheduled', 'running', 'paused', 'canceled', 'finished')"
  end

  down do
    run 'DROP TYPE IF EXISTS "auction_kinds"'
    run 'DROP TYPE IF EXISTS "auction_statuses"'
  end
end
