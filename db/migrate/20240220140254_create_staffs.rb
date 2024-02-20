# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table(:staffs) do
      primary_key :id
      column :name, String, null: false
      column :email, String, null: false
      column :phone, String, null: false
      column :active, TrueClass, null: false, default: true
      column :password_digest, String, null: false
      column :kind, :staff_kinds, null: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :email, unique: true
      index :phone, unique: true
    end
  end
end
