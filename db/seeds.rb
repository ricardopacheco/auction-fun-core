# frozen_string_literal: true

require "pry"
require "faker"

I18n.enforce_available_locales = false
Faker::Config.locale = "pt-BR"

# Constants
STOPWATCH_OPTIONS = [15, 30, 45, 60].freeze

# Start application
AuctionFunCore::Application.start(:core)

# Instantiate repos
auction_repository = AuctionFunCore::Repos::AuctionContext::AuctionRepository.new
staff_repository = AuctionFunCore::Repos::StaffContext::StaffRepository.new

# Create root staff. Create as a regular user using the normal flow and after that
# just change the type directly in the db.

root_staff_attributes = {
  kind: "root", name: "Root Bot", email: "rootbot@auctionfun.net",
  phone: Faker::PhoneNumber.unique.cell_phone_in_e164,
  password: "password", password_confirmation: "password"
}

AuctionFunCore::Operations::StaffContext::RegistrationOperation.call(root_staff_attributes) do |result|
  result.failure { |failure| raise "Error to create root staff: #{failure}" }
  result.success { |root| @root = root }
end
staff_repository.update(@root.id, kind: "root")

# Add common staff

common_staff_attributes = {
  name: "Staff Bot", email: "staffbot@auctionfun.net",
  phone: Faker::PhoneNumber.unique.cell_phone_in_e164,
  password: "password", password_confirmation: "password"
}

AuctionFunCore::Operations::StaffContext::RegistrationOperation.call(common_staff_attributes) do |result|
  result.failure { |failure| raise "Error to create common staff: #{failure}" }
  result.success { |staff| @staff = staff }
end

# Create some standard auctions
(1..15).each do |i|
  attributes = {
    staff_id: @staff.id, title: Faker::Commerce.product_name, description: Faker::Lorem.paragraph_by_chars,
    kind: "standard", started_at: i.hour.from_now, finished_at: i.day.from_now,
    initial_bid_cents: (i * 100), minimal_bid_cents: (i * 100)
  }
  AuctionFunCore::Operations::AuctionContext::CreateOperation.call(attributes) do |result|
    result.failure { |failure| raise "Error to create standard auction: #{failure}" }
    result.success { |auction| puts "Create standard auction with: #{auction.to_h}" }
  end
end

# Create some penny auctions
(1..10).each do |i|
  stopwatch = STOPWATCH_OPTIONS.sample
  started_at = i.hour.from_now
  finished_at = started_at + stopwatch.seconds

  attributes = {
    staff_id: @staff.id, title: Faker::Commerce.product_name, description: Faker::Lorem.paragraph_by_chars,
    kind: "penny", started_at: started_at, finished_at: finished_at, stopwatch: stopwatch
  }
  AuctionFunCore::Operations::AuctionContext::CreateOperation.call(attributes) do |result|
    result.failure { |failure| raise "Error to create penny auction: #{failure}" }
    result.success { |auction| puts "Create penny auction with: #{auction.to_h}" }
  end
end

# Create some closed auctions
(1..3).each do |i|
  attributes = {
    staff_id: @staff.id, title: Faker::Commerce.product_name, kind: "closed",
    started_at: i.hour.from_now, finished_at: i.day.from_now.end_of_day,
    initial_bid_cents: (i * 1000)
  }
  AuctionFunCore::Operations::AuctionContext::CreateOperation.call(attributes) do |result|
    result.failure { |failure| raise "Error to create closed auction: #{failure}" }
    result.success { |auction| puts "Create closed auction with: #{auction.to_h}" }
  end
end

# Add some users
100.times do
  attributes = {
    name: Faker::Name.name, email: Faker::Internet.unique.email,
    phone: Faker::PhoneNumber.unique.cell_phone_in_e164, password: "password",
    password_confirmation: "password"
  }
  AuctionFunCore::Operations::UserContext::RegistrationOperation.call(attributes) do |result|
    result.failure { |failure| raise "Error to create user: #{failure}" }
    result.success { |user| puts "Create user with: #{user.to_h}" }
  end
end

# Create some bids
auction_repository.all.each do |auction|
  next if auction.id.even?

  bid_params = {
    auction_id: auction.id,
    user_id: rand(2..100),
    value_cents: auction.minimal_bid_cents + (auction.minimal_bid_cents * 0.10)
  }

  "AuctionFunCore::Operations::BidContext::CreateBid#{auction.kind.capitalize}Operation".constantize.call(bid_params) do |result|
    result.failure { |failure| raise "Error to create bid: #{failure}" }
    result.success { |bid| puts "Create bid with: #{bid.to_h}" }
  end
end
