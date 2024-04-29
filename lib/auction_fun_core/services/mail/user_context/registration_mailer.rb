# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module UserContext
        # Service class responsible for sending registration emails to users.
        class RegistrationMailer
          include IdleMailer::Mailer
          include IdleMailer::TemplateManager

          # Initializes a new RegistrationMailer instance.
          #
          # @param user [ROM::Struct::User] The user object
          def initialize(user)
            @user = user
            mail.to = user.email
            mail.subject = I18n.t("mail.user_context.registration.subject")
          end

          # Returns the template name for the RegistrationMailer.
          #
          # @return [String] The template name.
          def self.template_name
            IdleMailer.config.templates.join("user_context/registration")
          end
        end
      end
    end
  end
end
