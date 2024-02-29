# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Entities::User, type: :entity do
  describe "#active?" do
    subject(:user) { Factory.structs[:user] }

    it "expect return true when user is active" do
      expect(user).to be_active
    end
  end

  describe "#inactive?" do
    subject(:user) { Factory.structs[:user, :inactive] }

    it "expect return false when user is not active" do
      expect(user).to be_inactive
    end
  end

  describe "#confirmed?" do
    context "when confirmed_at is present" do
      subject(:user) { Factory.structs[:user] }

      it "expect return true" do
        expect(user).to be_confirmed
      end
    end

    context "when confirmed_at is blank" do
      subject(:user) { Factory.structs[:user, confirmed_at: nil] }

      it "expect return false" do
        expect(user).not_to be_confirmed
      end
    end
  end

  describe "#email_confirmed?" do
    context "when email_confirmation_at is present" do
      subject(:user) { Factory.structs[:user] }

      it "expect return true" do
        expect(user).to be_email_confirmed
      end
    end

    context "when email_confirmation_at is blank" do
      subject(:user) { Factory.structs[:user, email_confirmation_at: nil] }

      it "expect return false" do
        expect(user).not_to be_email_confirmed
      end
    end
  end

  describe "#phone_confirmed?" do
    context "when phone_confirmation_at is present" do
      subject(:user) { Factory.structs[:user] }

      it "expect return true" do
        expect(user).to be_phone_confirmed
      end
    end

    context "when phone_confirmation_at is blank" do
      subject(:user) { Factory.structs[:user, phone_confirmation_at: nil] }

      it "expect return false" do
        expect(user).not_to be_phone_confirmed
      end
    end
  end

  describe "#info" do
    subject(:user) { Factory.structs[:user, :with_balance] }

    it "expect return hash with some user fields" do
      expect(user.info).to eq({
        active: user.active,
        balance_cents: user.balance_cents,
        balance_currency: user.balance_currency,
        confirmed_at: user.confirmed_at,
        created_at: user.created_at,
        email: user.email,
        email_confirmation_at: user.email_confirmation_at,
        email_confirmation_token: user.email_confirmation_token,
        id: user.id,
        name: user.name,
        phone: user.phone,
        phone_confirmation_at: user.phone_confirmation_at,
        phone_confirmation_token: user.phone_confirmation_token,
        updated_at: user.updated_at
      })
    end
  end

  describe "#balance" do
    subject(:user) { Factory.structs[:user, :with_balance] }

    it "expect return false when user is not active" do
      expect(user.balance).to be_a_instance_of(Money)
    end
  end
end
