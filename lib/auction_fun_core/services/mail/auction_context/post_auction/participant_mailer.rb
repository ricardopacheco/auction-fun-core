# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module AuctionContext
        module PostAuction
          class ParticipantMailer
            include IdleMailer::Mailer
            include IdleMailer::TemplateManager

            # @param auction [ROM::Struct::Auction] The auction object
            # @param participant [ROM::Struct::User] The user object
            # @param statistics [OpenStruct] Statistics object
            def initialize(auction, participant, statistics)
              @auction = auction
              @participant = participant
              @statistics = statistics
              mail.to = participant.email
              mail.subject = I18n.t("mail.auction_context.post_auction.participant_mailer.subject", title: @auction.title)
            end

            def self.template_name
              IdleMailer.config.templates.join("auction_context/post_auction/participant")
            end
          end
        end
      end
    end
  end
end
