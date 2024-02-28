# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Workers::Services::Mail::UserContext::RegistrationMailerJob, type: :worker do
  let(:user) { Factory[:user] }
  let(:user_repo) { AuctionFunCore::Repos::UserRepository.new }
  let(:mailer_class) { AuctionFunCore::Services::Mail::UserContext::RegistrationMailer }
  let(:mailer) { mailer_class.new(user) }

  describe "#perform" do
    subject(:worker) { described_class.new }

    context "when attributes are valid" do
      before do
        allow(mailer_class).to receive(:new).with(user).and_return(mailer)
        allow(mailer).to receive(:deliver).and_return(true)
      end

      it "expect trigger registration mailer service" do
        worker.perform(user.id)

        expect(mailer).to have_received(:deliver).once
      end
    end

    context "when an exception occours but retry limit is not reached" do
      before do
        stub_const("::AuctionFunCore::Workers::ApplicationJob::MAX_RETRIES", 1)
        allow(AuctionFunCore::Application[:logger]).to receive(:error)
      end

      it "expect rescue/capture exception and reschedule job" do
        expect { worker.perform(nil) }.to change(described_class.jobs, :size).from(0).to(1)

        expect(AuctionFunCore::Application[:logger]).to have_received(:error).at_least(:once)
      end
    end

    context "when the exception reaches the retry limit" do
      before do
        stub_const("::AuctionFunCore::Workers::ApplicationJob::MAX_RETRIES", 0)
        allow(AuctionFunCore::Application[:logger]).to receive(:error)
      end

      it "expect raise exception and stop retry" do
        expect { worker.perform(nil) }.to raise_error(ROM::TupleCountMismatchError)

        expect(AuctionFunCore::Application[:logger]).to have_received(:error).at_least(:once)
      end
    end
  end
end
