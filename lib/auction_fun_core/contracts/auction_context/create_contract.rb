# frozen_string_literal: true

module AuctionFunCore
  module Contracts
    module AuctionContext
      # This class is designed to validate the creation of new auctions.
      # It includes various validations such as staff existence, auction kind, timing, and initial bids.
      #
      # @example Creating a new auction
      #   contract = AuctionFunCore::Contracts::AuctionContext::CreateContract.new
      #   attributes = {
      #     staff_id: 1,
      #     title: "Rare Antique Vase",
      #     kind: "standard",
      #     started_at: Time.current + 5.days,
      #     finished_at: Time.current + 10.days,
      #     initial_bid_cents: 5000
      #   }
      #   result = contract.call(attributes)
      #   if result.success?
      #     puts "Auction created successfully."
      #   else
      #     puts "Failed to create auction: #{result.errors.to_h}"
      #   end
      #
      class CreateContract < Contracts::ApplicationContract
        include AuctionFunCore::Business::Configuration

        # Additional validations specific for non-penny auctions.
        REQUIRED_FINISHED_AT = AUCTION_KINDS - ["penny"]

        # Repository initialized to retrieve staff data for validation.
        option :staff_repo, default: proc { Repos::StaffContext::StaffRepository.new }

        # Defines necessary parameters and initializes some default values.
        params do
          required(:staff_id).filled(:integer)
          required(:title).filled(:string, size?: (AUCTION_MIN_TITLE_LENGTH..AUCTION_MAX_TITLE_LENGTH))
          required(:kind).value(included_in?: AUCTION_KINDS)
          required(:started_at).filled(:time)
          optional(:description)
          optional(:finished_at).filled(:time)
          optional(:initial_bid_cents).filled(:integer)
          optional(:stopwatch).filled(:integer)

          # Parameters specifying the required input types and fields.
          before(:value_coercer) do |result|
            result.to_h.compact
          end

          # By default, the minimum bid cents is initially equal to initial_bid_cents.
          after(:value_coercer) do |result|
            result.update(minimal_bid_cents: result[:initial_bid_cents]) if result[:initial_bid_cents]
          end
        end

        # Validates the existence of the staff.
        rule(:staff_id) do |context:|
          context[:staff] ||= staff_repo.by_id(value)
          key.failure(I18n.t("contracts.errors.custom.default.not_found")) unless context[:staff]
        end

        # Validates that the starting time of the auction is in the future.
        rule(:started_at) do
          key.failure(I18n.t("contracts.errors.custom.default.future")) if key? && value <= Time.current
        end

        # Validates that the finished_at time is specified for auctions types that require it,
        # and is not specified for "penny" auctions.
        rule(:finished_at, :kind) do
          if key?(:kind) && !key?(:finished_at) && REQUIRED_FINISHED_AT.include?(values[:kind])
            key.failure(I18n.t("contracts.errors.filled?"))
          end
        end

        # Validates that the auction end time is later than the start time.
        rule(:finished_at, :started_at) do
          if key?(:finished_at) && (values[:finished_at] <= values[:started_at])
            key.failure(I18n.t("contracts.errors.custom.auction_context.create.finished_at"))
          end
        end

        # Validates the initial bid amount based on auction type.
        rule(:initial_bid_cents) do
          # Must be specified and positive for non-penny auction types.
          key.failure(I18n.t("contracts.errors.filled?")) if !key? && REQUIRED_FINISHED_AT.include?(values[:kind])

          if key? && REQUIRED_FINISHED_AT.include?(values[:kind]) && values[:initial_bid_cents] <= 0
            key.failure(I18n.t("contracts.errors.gt?", num: 0))
          end

          # Must be zero for penny auctions to ensure fairness.
          if key? && values[:kind] == "penny" && !values[:initial_bid_cents].zero?
            key.failure(I18n.t("contracts.errors.eql?", left: 0))
          end
        end

        # Validates stopwatch settings for penny auctions.
        rule(:stopwatch) do
          # Stopwatch must be specified for penny auctions.
          key.failure(I18n.t("contracts.errors.filled?")) if !key? && values[:kind] == "penny"

          # Stopwatch value must fall within the specified range.
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
