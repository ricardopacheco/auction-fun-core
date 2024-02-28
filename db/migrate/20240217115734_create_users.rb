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
      column :email_confirmation_token, String, size: 20
      column :phone_confirmation_token, String, size: 6
      column :email_confirmation_at, DateTime
      column :phone_confirmation_at, DateTime
      column :confirmed_at, DateTime
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :email, unique: true
      index :phone, unique: true
      index :email_confirmation_token, unique: true
      index :phone_confirmation_token, unique: true
    end
  end
end
