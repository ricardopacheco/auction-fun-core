# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Entities::Staff, type: :entity do
  describe "#active?" do
    subject(:staff) { Factory.structs[:staff] }

    it "expect return true when staff is active" do
      expect(staff).to be_active
    end
  end

  describe "#inactive?" do
    subject(:staff) { Factory.structs[:staff, :inactive] }

    it "expect return false when staff is not active" do
      expect(staff).to be_inactive
    end
  end

  describe "#info" do
    subject(:staff) { Factory.structs[:staff] }

    it "expect return hash with some staff fields" do
      expect(staff.info).to eq({
        active: staff.active,
        created_at: staff.created_at,
        email: staff.email,
        id: staff.id,
        kind: staff.kind,
        name: staff.name,
        phone: staff.phone,
        updated_at: staff.updated_at
      })
    end
  end
end
