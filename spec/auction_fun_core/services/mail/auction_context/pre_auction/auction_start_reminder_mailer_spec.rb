# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Services::Mail::AuctionContext::PreAuction::AuctionStartReminderMailer, type: :mailer do
  let(:default_email_system) { AuctionFunCore::Application[:settings].default_email_system }

  describe "#deliver" do
    subject(:mailer) { described_class.new(auction, participant) }

    let(:auction) { Factory.structs[:auction, :default_scheduled_standard, id: 1, started_at: 3.hours.from_now] }

    context "when participant has invalid data" do
      let(:participant) { Factory.structs[:user, id: 1, email: nil] }

      it "expect raise error" do
        expect { mailer.deliver }.to raise_error(
          ArgumentError, "SMTP To address may not be blank: []"
        )
      end
    end

    context "when participant has valid data" do
      let(:participant) { Factory[:user] }

      subject(:mailer) { described_class.new(auction, participant).deliver }

      it "expect send email with correct data" do
        expect(mailer).to be_a_instance_of(Mail::Message)
        expect(mail_from(default_email_system)).to be_truthy
        expect(
          sent_mail_to?(
            participant.email,
            I18n.t("mail.auction_context.pre_auction.auction_start_reminder_mailer.subject", title: auction.title)
          )
        ).to be_truthy
      end
    end
  end
end
