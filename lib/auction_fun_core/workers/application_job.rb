# frozen_string_literal: true

require "sidekiq"

module AuctionFunCore
  module Workers
    # Abstract base class for background jobs.
    # @abstract
    class ApplicationJob
      MAX_RETRIES = 15
      include Sidekiq::Job

      # Captures an exception and logs it along with additional attributes.
      #
      # @param exception [Exception] The exception to be captured.
      # @param attributes [Hash] Additional attributes to be logged.
      # @return [void]
      def capture_exception(exception, attributes = {})
        Application[:logger].error("#{exception.message}. Parameters: #{attributes}")
      end

      # Calculates an exponential backoff interval for retrying the job.
      #
      # @param retry_count [Integer] The current retry count.
      # @param measure [String] The unit of time to measure the interval.
      # @return [Integer] The backoff interval in the specified measure.
      def backoff_exponential_job(retry_count, measure = "seconds")
        max_retries = Float(2**retry_count)

        rand(0..max_retries).send(measure)
      end
    end
  end
end
