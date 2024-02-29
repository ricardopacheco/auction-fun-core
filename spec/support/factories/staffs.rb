# frozen_string_literal: true

Factory.define(:staff, struct_namespace: AuctionFunCore::Entities) do |f|
  f.name { fake(:name, :name) }
  f.email { fake(:internet, :email) }
  f.phone { fake(:phone_number, :cell_phone_in_e164).tr_s("^0-9", "") }
  f.password_digest { BCrypt::Password.create("password") }
  f.kind { "common" }
  f.active { true }

  f.trait :with_root_kind do |t|
    t.kind { "root" }
  end

  f.trait :inactive do |t|
    t.active { false }
  end
end
