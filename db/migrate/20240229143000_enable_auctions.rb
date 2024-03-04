# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table(:auctions) do
      primary_key :id
      foreign_key :staff_id, :staffs, null: false
      column :title, String, null: false
      column :description, :text
      column :kind, :auction_kinds, null: false
      column :status, :auction_statuses, null: false
      column :started_at, DateTime, null: false
      column :finished_at, DateTime
      column :stopwatch, Integer, null: false, default: 0
      column :initial_bid_cents, Integer, null: false, default: 0
      column :initial_bid_currency, String, null: false, default: "USD"
      column :minimal_bid_cents, Integer, null: false, default: 0
      column :minimal_bid_currency, String, null: false, default: "USD"
      column :metadata, :jsonb, null: false, default: "{}"
      column :statistics, :jsonb, null: false, default: "{}"

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end

    add_index :auctions, %i[staff_id], name: "idx_admin"
    add_index :auctions, %i[kind status], name: "idx_kind_status"
  end
end
