# frozen_string_literal: true

Factory.define(:auction, struct_namespace: AuctionFunCore::Entities) do |f|
  f.association(:staff)
  f.title { fake(:commerce, :product_name) }
  f.description { fake(:lorem, :paragraph) }
  f.initial_bid_cents { 0 }
  f.initial_bid_currency { AuctionFunCore::Application[:settings].default_currency }
  f.minimal_bid_cents { 0 }
  f.minimal_bid_currency { AuctionFunCore::Application[:settings].default_currency }

  f.trait :with_minimal_bid do |t|
  end

  f.trait :with_kind_standard do |t|
    t.kind { "standard" }
  end

  f.trait :with_kind_penny do |t|
    t.kind { "penny" }
  end

  f.trait :with_kind_closed do |t|
    t.kind { "closed" }
  end

  f.trait :with_status_scheduled do |t|
    t.status { "scheduled" }
  end

  f.trait :with_status_running do |t|
    t.status { "running" }
  end

  f.trait :with_status_paused do |t|
    t.status { "paused" }
  end

  f.trait :with_status_canceled do |t|
    t.status { "canceled" }
  end

  f.trait :with_status_finished do |t|
    t.status { "finished" }
  end

  f.trait :started_in_one_hour_from_now do |t|
    t.started_at { 1.hour.from_now }
  end

  f.trait :started_in_one_day_from_now do |t|
    t.started_at { 1.day.from_now }
  end

  f.trait :finished_in_two_days_from_now do |t|
    t.started_at { 1.day.from_now }
    t.finished_at { 2.days.from_now }
  end

  f.trait :default_standard do |t|
    t.kind { "standard" }

    t.started_at { 1.hour.from_now }
    t.finished_at { 1.week.from_now }
    t.initial_bid_cents { 100 }
    t.minimal_bid_cents { 100 }
  end

  f.trait :default_running_standard do |t|
    t.kind { "standard" }
    t.status { "running" }

    t.started_at { 1.hour.ago }
    t.finished_at { 1.day.from_now }
    t.initial_bid_cents { 100 }
    t.minimal_bid_cents { 100 }
  end

  f.trait :default_finished_standard do |t|
    t.kind { "standard" }
    t.status { "finished" }

    t.started_at { 2.days.ago }
    t.finished_at { 1.day.ago }
    t.initial_bid_cents { 100 }
    t.minimal_bid_cents { 100 }
  end

  f.trait :default_paused_standard do |t|
    t.kind { "standard" }
    t.status { "paused" }

    t.started_at { 1.hour.ago }
    t.finished_at { 1.day.from_now }
    t.initial_bid_cents { 100 }
    t.minimal_bid_cents { 100 }
  end

  f.trait :default_penny do |t|
    t.kind { "penny" }

    t.stopwatch { AuctionFunCore::Business::Configuration::AUCTION_STOPWATCH_MIN_VALUE }
    t.started_at { 1.hour.from_now }
  end

  f.trait :default_running_penny do |t|
    t.kind { "penny" }
    t.status { "running" }

    t.started_at { 1.hour.ago }
    t.finished_at { 60.seconds.from_now }
    t.initial_bid_cents { 100 }
  end

  f.trait :default_closed do |t|
    t.kind { "closed" }

    t.initial_bid_cents { 100 }
    t.started_at { 1.hour.from_now }
    t.finished_at { 1.week.from_now }
  end

  f.trait :default_running_closed do |t|
    t.kind { "closed" }
    t.status { "running" }

    t.started_at { 1.hour.ago }
    t.finished_at { 1.day.from_now }
    t.initial_bid_cents { 100 }
  end
end
