# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :bids do
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :auction_id, :auctions, null: false

      column :value_cents, Integer, null: false, default: 0
      column :value_currency, String, null: false, default: "USD"

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end

    add_index :bids, %i[auction_id user_id], name: "idx_user_auction"
  end
end
