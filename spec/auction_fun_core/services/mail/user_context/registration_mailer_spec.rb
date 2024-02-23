# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Services::Mail::UserContext::RegistrationMailer, type: :mailer do
  let(:default_email_system) { AuctionFunCore::Application[:settings].default_email_system }

  describe "#deliver" do
    subject(:mailer) { described_class.new(user) }

    context "when user has invalid data" do
      let(:user) { Factory.structs[:user, id: 1, email: nil] }

      it "expect raise error" do
        expect { mailer.deliver }.to raise_error(
          ArgumentError, "SMTP To address may not be blank: []"
        )
      end
    end

    context "when user has valid data" do
      let(:user) { Factory.structs[:user, id: 1] }

      subject(:mailer) { described_class.new(user).deliver }

      it "expect send email with correct data" do
        expect(mailer).to be_a_instance_of(Mail::Message)
        expect(mail_from(default_email_system)).to be_truthy
        expect(sent_mail_to?(user.email, I18n.t("mail.user_context.registration.subject"))).to be_truthy
      end
    end
  end
end
