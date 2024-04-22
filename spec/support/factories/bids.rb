# frozen_string_literal: true

Factory.define(:bid, struct_namespace: AuctionFunCore::Entities) do |f|
  f.association(:auction, :default_scheduled_standard)
  f.association(:user)
end
