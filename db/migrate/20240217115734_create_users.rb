# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table(:users) do
      primary_key :id
      column :name, String, null: false
      column :email, String, null: false
      column :phone, String, null: false
      column :password_digest, String, null: false
      column :active, TrueClass, null: false, default: true
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
