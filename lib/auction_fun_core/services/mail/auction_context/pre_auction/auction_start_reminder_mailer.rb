# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module AuctionContext
        module PreAuction
          # # Service class responsible for sending auction start reminder emails to participants.
          class AuctionStartReminderMailer
            include IdleMailer::Mailer
            include IdleMailer::TemplateManager

            # Initializes a new AuctionStartReminderMailer instance.
            #
            # @param auction [ROM::Struct::Auction] The auction object
            # @param participant [ROM::Struct::User] The participant object
            def initialize(auction, participant)
              @auction = auction
              @participant = participant
              mail.to = participant.email
              mail.subject = I18n.t("mail.auction_context.pre_auction.auction_start_reminder_mailer.subject", title: @auction.title)
            end

            # Returns the template name for the AuctionStartReminderMailer.
            #
            # @return [String] The template name.
            def self.template_name
              IdleMailer.config.templates.join("auction_context/pre_auction/auction_start_reminder")
            end
          end
        end
      end
    end
  end
end
