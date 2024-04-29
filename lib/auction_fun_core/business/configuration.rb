# frozen_string_literal: true

module AuctionFunCore
  module Business
    # The Configuration module contains constants that configure various aspects of auctions,
    # user settings, and other business rules within the AuctionFun application.
    module Configuration
      # An array of available auction kinds derived from auction relations.
      # @return [Array<String>] a list of all possible auction kinds
      AUCTION_KINDS = Relations::Auctions::KINDS.values

      # An array of valid auction statuses derived from auction relations.
      # @return [Array<String>] a list of all valid auction statuses
      AUCTION_STATUSES = Relations::Auctions::STATUSES.values

      # The minimum length for an auction title.
      # @return [Integer] the minimum number of characters allowed in an auction title
      AUCTION_MIN_TITLE_LENGTH = 6

      # The maximum length for an auction title.
      # @return [Integer] the maximum number of characters allowed in an auction title
      AUCTION_MAX_TITLE_LENGTH = 255

      # The minimum value for the auction stopwatch timer.
      # @return [Integer] the minimum seconds count for the auction stopwatch timer
      AUCTION_STOPWATCH_MIN_VALUE = 15

      # The maximum value for the auction stopwatch timer.
      # @return [Integer] the maximum seconds count for the auction stopwatch timer
      AUCTION_STOPWATCH_MAX_VALUE = 60

      # The minimum length for a user's name.
      # @return [Integer] the minimum number of characters allowed in a person's name
      MIN_NAME_LENGTH = 6

      # The maximum length for a user's name.
      # @return [Integer] the maximum number of characters allowed in a person's name
      MAX_NAME_LENGTH = 128

      # The minimum length for a user's password.
      # @return [Integer] the minimum number of characters required in a person's password
      MIN_PASSWORD_LENGTH = 6

      # The maximum length for a user's password.
      # @return [Integer] the maximum number of characters allowed in a person's password
      MAX_PASSWORD_LENGTH = 128
    end
  end
end
