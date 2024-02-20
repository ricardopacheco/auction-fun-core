# frozen_string_literal: true

require "action_mailer"

module AuctionFunCore
  module Infra
    module Mail
      class UserContextMailer < ApplicationMailer
        layout "mailer"

        def registration(user)
          @user = user

          html_template = load_template("registration.html.erb")
          text_template = load_template("registration.text.erb")

          mail(to: @user.email, subject: "Welcome") do |format|
            format.html { render html: html_template.render(self, locals: {user: @user}) }
            format.text { render plain: text_template.render(self, locals: {user: @user}) }
          end
        end
      end
    end
  end
end
