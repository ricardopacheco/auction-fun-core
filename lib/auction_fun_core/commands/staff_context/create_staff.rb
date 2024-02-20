# frozen_string_literal: true

module AuctionFunCore
  module Commands
    module StaffContext
      ##
      # Abstract base class for insert new tuples on staffs table.
      # @abstract
      class CreateStaff < ROM::Commands::Create[:sql]
        relation :staffs
        register_as :create
        result :one

        use :timestamps
        timestamp :created_at, :updated_at
      end
    end
  end
end
