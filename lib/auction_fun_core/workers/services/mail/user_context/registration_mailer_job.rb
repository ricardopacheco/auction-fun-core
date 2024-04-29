# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Services
      module Mail
        module UserContext
          ##
          # Background job class responsible for queuing registration emails.
          class RegistrationMailerJob < AuctionFunCore::Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]

            # Initializes a new RegistrationMailerJob instance.
            #
            # @param user_id [Integer] The ID of the user.
            # @param retry_count [Integer] The current retry count for the job.
            # @return [void]
            def perform(user_id, retry_count = 0)
              user = user_repository.by_id!(user_id)

              registration_mailer.new(user).deliver
            rescue => e
              capture_exception(e, {user_id: user_id, retry_count: retry_count})
              raise e if retry_count >= MAX_RETRIES

              interval = backoff_exponential_job(retry_count)
              self.class.perform_at(interval, user_id, retry_count + 1)
            end

            private

            # Directly specifies the class to be called due to non-standard dependency injection.
            # @return [Class] The registration mailer class.
            def registration_mailer
              AuctionFunCore::Services::Mail::UserContext::RegistrationMailer
            end
          end
        end
      end
    end
  end
end
