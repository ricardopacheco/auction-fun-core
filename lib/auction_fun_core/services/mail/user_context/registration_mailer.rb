# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module UserContext
        class RegistrationMailer
          include IdleMailer::Mailer
          include IdleMailer::TemplateManager

          # @param user [ROM::Struct::User] The user object
          def initialize(user)
            @user = user
            mail.to = user.email
            mail.subject = I18n.t("mail.user_context.registration.subject")
          end

          def self.template_name
            IdleMailer.config.templates.join("user_context/registration")
          end
        end
      end
    end
  end
end
