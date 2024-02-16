# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run 'CREATE EXTENSION "unaccent"'
    run 'CREATE EXTENSION "hstore"'
  end

  down do
    run 'DROP EXTENSION IF EXISTS "unaccent"'
    run 'DROP EXTENSION IF EXISTS "hstore"'
  end
end
