# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      # Contract class to create new auctions.
      class CreateContract < Contracts::ApplicationContract
        include AuctionFunCore::Business::Configuration

        REQUIRED_FINISHED_AT = AUCTION_KINDS - ["penny"]

        option :staff_repo, default: proc { Repos::StaffContext::StaffRepository.new }

        # @param [Hash] opts Sets an allowed list of parameters, as well as some initial validations.
        params do
          required(:staff_id).filled(:integer)
          required(:title).filled(:string, size?: (AUCTION_MIN_TITLE_LENGTH..AUCTION_MAX_TITLE_LENGTH))
          required(:kind).value(included_in?: AUCTION_KINDS)
          required(:started_at).filled(:time)
          optional(:description)
          optional(:finished_at).filled(:time)
          optional(:initial_bid_cents).filled(:integer)
          optional(:stopwatch).filled(:integer)

          # Keys with a blank value are discarded.
          before(:value_coercer) do |result|
            result.to_h.compact
          end

          # By default, the minimum bid cents is initially equal to initial_bid_cents.
          after(:value_coercer) do |result|
            result.update(minimal_bid_cents: result[:initial_bid_cents]) if result[:initial_bid_cents]
          end
        end

        # Validation for staff.
        # Validate whether the given staff is valid at the database level.
        rule(:staff_id) do |context:|
          context[:staff] ||= staff_repo.by_id(value)
          key.failure(I18n.t("contracts.errors.custom.default.not_found")) unless context[:staff]
        end

        # Validation for started_at.
        # Validates if the entered date is greater than or equal to the current time.
        rule(:started_at) do
          key.failure(I18n.t("contracts.errors.custom.default.future")) if key? && value <= Time.current
        end

        # Specific validation when the auction type is informed and it is not penny,
        # it must be mandatory to inform the auction closing date/time
        rule(:finished_at, :kind) do
          if key?(:kind) && !key?(:finished_at) && REQUIRED_FINISHED_AT.include?(values[:kind])
            key.failure(I18n.t("contracts.errors.filled?"))
          end
        end

        # Basic specific validation to check if the auction end time
        # is less than or equal to the start time.
        rule(:finished_at, :started_at) do
          if key?(:finished_at) && (values[:finished_at] <= values[:started_at])
            key.failure(I18n.t("contracts.errors.custom.auction_context.create.finished_at"))
          end
        end

        # Validation for initial bid amount.
        #
        rule(:initial_bid_cents) do
          # Must be filled if auction kind is not type penny.
          key.failure(I18n.t("contracts.errors.filled?")) if !key? && REQUIRED_FINISHED_AT.include?(values[:kind])

          # Must be greater than zero if action kind is not type penny.
          if key? && REQUIRED_FINISHED_AT.include?(values[:kind]) && values[:initial_bid_cents] <= 0
            key.failure(I18n.t("contracts.errors.gt?", num: 0))
          end

          # Must be equal to zero if auction kind is type penny.
          if key? && values[:kind] == "penny" && !values[:initial_bid_cents].zero?
            key.failure(I18n.t("contracts.errors.eql?", left: 0))
          end
        end

        # Validation for stopwatch.
        #
        rule(:stopwatch) do
          # Must be filled if auction kind is type penny.
          key.failure(I18n.t("contracts.errors.filled?")) if !key? && values[:kind] == "penny"

          # Must be an integer between 15 and 60.
          if key? && values[:kind] == "penny" && !value.between?(AUCTION_STOPWATCH_MIN_VALUE, AUCTION_STOPWATCH_MAX_VALUE)
            key.failure(
              I18n.t(
                "contracts.errors.included_in?.arg.range",
                list_left: AUCTION_STOPWATCH_MIN_VALUE, list_right: AUCTION_STOPWATCH_MAX_VALUE
              )
            )
          end
        end
      end
    end
  end
end
