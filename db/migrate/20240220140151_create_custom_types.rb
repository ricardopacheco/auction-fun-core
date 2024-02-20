# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run "CREATE TYPE staff_kinds AS ENUM('root', 'common')"
  end

  down do
    run 'DROP TYPE IF EXISTS "staff_kinds"'
  end
end
