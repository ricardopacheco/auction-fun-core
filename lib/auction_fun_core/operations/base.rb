# frozen_string_literal: true

module AuctionFunCore
  module Operations
    # Abstract base class for operations.
    # @abstract
    class Base
      include Dry::Monads[:do, :maybe, :result, :try]
    end
  end
end
