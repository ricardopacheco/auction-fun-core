# frozen_string_literal: true

Factory.define(:user, struct_namespace: AuctionFunCore::Entities) do |f|
  f.name { fake(:name, :name) }
  f.email { fake(:internet, :email) }
  f.phone { fake(:phone_number, :cell_phone_in_e164).tr_s("^0-9", "") }
  f.password_digest { BCrypt::Password.create("password") }
  f.email_confirmation_at { Time.current - 1.day }
  f.phone_confirmation_at { Time.current - 1.day }
  f.confirmed_at { Time.current }
  f.active { true }

  f.trait :inactive do |t|
    t.active { false }
  end

  f.trait :unconfirmed do |t|
    t.email_confirmation_token { nil }
    t.phone_confirmation_token { nil }
    t.confirmed_at { nil }
  end

  f.trait :with_unconfirmed_email do |t|
    t.email_confirmation_at { nil }
  end

  f.trait :with_unconfirmed_phone do |t|
    t.phone_confirmation_at { nil }
  end

  f.trait :with_email_confirmation_token do |t|
    t.email_confirmation_token { AuctionFunCore::Business::TokenGenerator.generate_email_token }
  end

  f.trait :with_phone_confirmation_token do |t|
    t.phone_confirmation_token { AuctionFunCore::Business::TokenGenerator.generate_phone_token }
  end

  f.trait :with_balance do |t|
    t.balance_cents { 1000 }
    t.balance_currency { Money.default_currency }
  end
end
