# frozen_string_literal: true

module AuctionFunCore
  module Business
    module Configuration
      AUCTION_KINDS = Relations::Auctions::KINDS.values
      AUCTION_STATUSES = Relations::Auctions::STATUSES.values
      AUCTION_MIN_TITLE_LENGTH = 6
      AUCTION_MAX_TITLE_LENGTH = 255
      AUCTION_STOPWATCH_MIN_VALUE = 15
      AUCTION_STOPWATCH_MAX_VALUE = 60
      MIN_NAME_LENGTH = 6
      MAX_NAME_LENGTH = 128
      MIN_PASSWORD_LENGTH = 6
      MAX_PASSWORD_LENGTH = 128
    end
  end
end
