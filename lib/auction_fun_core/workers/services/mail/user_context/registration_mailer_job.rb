# frozen_string_literal: true

module AuctionFunCore
  module Workers
    module Services
      module Mail
        module UserContext
          ##
          # Background job class responsible for adding emails to the queue.
          #
          class RegistrationMailerJob < AuctionFunCore::Workers::ApplicationJob
            include Import["repos.user_context.user_repository"]

            # @param user_id [Integer] user ID
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

            # Since the shipping code structure does not follow project conventions,
            # making the default injection dependency would be more complicated.
            # Therefore, here I directly explain the class to be called.
            def registration_mailer
              AuctionFunCore::Services::Mail::UserContext::RegistrationMailer
            end
          end
        end
      end
    end
  end
end
