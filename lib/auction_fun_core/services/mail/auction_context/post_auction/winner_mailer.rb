# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module AuctionContext
        module PostAuction
          # Service class responsible for sending emails to auction winners.
          class WinnerMailer
            include IdleMailer::Mailer
            include IdleMailer::TemplateManager

            # Initializes a new WinnerMailer instance.
            #
            # @param auction [ROM::Struct::Auction] The auction object
            # @param winner [ROM::Struct::User] The winner object
            # @param statistics [OpenStruct] Statistics object
            def initialize(auction, winner, statistics)
              @auction = auction
              @winner = winner
              @statistics = statistics
              mail.to = winner.email
              mail.subject = I18n.t("mail.auction_context.post_auction.winner_mailer.subject", title: @auction.title)
            end

            # Returns the template name for the WinnerMailer.
            #
            # @return [String] The template name.
            def self.template_name
              IdleMailer.config.templates.join("auction_context/post_auction/winner")
            end
          end
        end
      end
    end
  end
end
