# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module UserContext
      ##
      # Abstract base class for insert new tuples on users table.
      # @abstract
      class CreateUser < ROM::Commands::Create[:sql]
        relation :users
        register_as :create
        result :one

        use :timestamps
        timestamp :created_at, :updated_at
      end
    end
  end
end
