# frozen_string_literal: true

module AuctionFunCore
  module Infra
    module Mail
      class ApplicationMailer < ActionMailer::Base
        append_view_path "infra/mail/views"
        layout "layouts/mailer"

        protected

        def load_template(filename, filepath = Application[:settings].mailer_path)
          template_path = File.join("#{filepath}/#{self.class.mailer_name}", filename)
          handler = ActionView::Template.handler_for_extension(:erb)
          template_source = File.read(template_path)

          ActionView::Template.new(template_source, template_path, handler, {})
        end
      end
    end
  end
end
