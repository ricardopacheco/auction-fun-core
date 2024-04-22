# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Services::Mail::AuctionContext::PostAuction::WinnerMailer, type: :mailer do
  let(:default_email_system) { AuctionFunCore::Application[:settings].default_email_system }

  describe "#deliver" do
    subject(:mailer) { described_class.new(auction, winner, statistics) }

    context "when winner has invalid data" do
      let(:winner) { Factory.structs[:user, email: nil] }
      let(:auction) { Factory.structs[:auction, id: 1] }
      let(:statistics) { OpenStruct.new(auction_date: Date.current) }

      it "expect raise error" do
        expect { mailer.deliver }.to raise_error(
          ArgumentError, "SMTP To address may not be blank: []"
        )
      end
    end

    context "when winner has valid data" do
      let(:winner) { Factory[:user] }
      let(:auction) { Factory[:auction, :default_finished_standard, winner_id: winner.id] }
      let(:bid) { Factory[:bid, auction_id: auction.id, user_id: winner.id, value_cents: auction.minimal_bid_cents] }
      let(:statistics) do
        OpenStruct.new(
          auction_total_bids: 1, winner_bid: auction.minimal_bid_cents, winner_total_bids: 1,
          auction_date: Date.current
        )
      end

      subject(:mailer) { described_class.new(auction, winner, statistics).deliver }

      it "expect send email with correct data" do
        expect(mailer).to be_a_instance_of(Mail::Message)
        expect(mail_from(default_email_system)).to be_truthy
        expect(
          sent_mail_to?(
            winner.email,
            I18n.t("mail.auction_context.post_auction.winner_mailer.subject", title: auction.title)
          )
        ).to be_truthy
      end
    end
  end
end
