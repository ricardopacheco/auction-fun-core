# frozen_string_literal: true

module AuctionFunCore
  module Infra
    module Mail
      module UserContext
        class RegistrationMailer
          include IdleMailer::Mailer
          include IdleMailer::TemplateManager

          def initialize(user)
            @user = user
            mail.to = user.email
            mail.subject = "Welcome to AuctionFun"
          end

          def self.template_name
            IdleMailer.config.templates.join("user_context/registration")
          end
        end
      end
    end
  end
end
