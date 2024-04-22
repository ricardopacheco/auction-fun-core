# frozen_string_literal: true

module AuctionFunCore
  module Services
    module Mail
      module AuctionContext
        module PostAuction
          class WinnerMailer
            include IdleMailer::Mailer
            include IdleMailer::TemplateManager

            # @param auction [ROM::Struct::Auction] The auction object
            # @param winner [ROM::Struct::User] The user object
            # @param statistics [OpenStruct] Statistics object
            def initialize(auction, winner, statistics)
              @auction = auction
              @winner = winner
              @statistics = statistics
              mail.to = winner.email
              mail.subject = I18n.t("mail.auction_context.post_auction.winner_mailer.subject", title: @auction.title)
            end

            def self.template_name
              IdleMailer.config.templates.join("auction_context/post_auction/winner")
            end
          end
        end
      end
    end
  end
end
