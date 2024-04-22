# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Services::Mail::AuctionContext::PostAuction::ParticipantMailer, type: :mailer do
  let(:default_email_system) { AuctionFunCore::Application[:settings].default_email_system }

  describe "#deliver" do
    subject(:mailer) { described_class.new(auction, participant, statistics) }

    context "when participant has invalid data" do
      let(:participant) { Factory.structs[:user, id: 1, email: nil] }
      let(:auction) { Factory.structs[:auction, :default_finished_standard, id: 1] }
      let(:statistics) { OpenStruct.new(auction_date: Date.current) }

      it "expect raise error" do
        expect { mailer.deliver }.to raise_error(
          ArgumentError, "SMTP To address may not be blank: []"
        )
      end
    end

    context "when participant has valid data" do
      let(:winner) { Factory[:user] }
      let(:participant) { Factory[:user] }
      let(:auction) { Factory[:auction, :default_finished_standard, winner_id: winner.id] }
      let(:statistics) do
        OpenStruct.new(
          auction_total_bids: 2, winner_bid: (auction.minimal_bid_cents * 2), winner_total_bids: 1,
          auction_date: Date.current
        )
      end

      subject(:mailer) { described_class.new(auction, participant, statistics).deliver }

      it "expect send email with correct data" do
        expect(mailer).to be_a_instance_of(Mail::Message)
        expect(mail_from(default_email_system)).to be_truthy
        expect(
          sent_mail_to?(
            participant.email,
            I18n.t("mail.auction_context.post_auction.participant_mailer.subject", title: auction.title)
          )
        ).to be_truthy
      end
    end
  end
end
