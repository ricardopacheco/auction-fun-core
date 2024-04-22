# frozen_string_literal: true

require "sidekiq"

module AuctionFunCore
  module Workers
    # Abstract base class for background jobs.
    # @abstract
    class ApplicationJob
      MAX_RETRIES = 15
      include Sidekiq::Job

      def capture_exception(exception, attributes = {})
        Application[:logger].error("#{exception.message}. Parameters: #{attributes}")
      end

      def backoff_exponential_job(retry_count, measure = "seconds")
        max_retries = Float(2**retry_count)

        rand(0..max_retries).send(measure)
      end
    end
  end
end
