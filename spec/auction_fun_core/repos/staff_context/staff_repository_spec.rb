# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Repos::StaffContext::StaffRepository, type: :repo do
  subject(:repo) { described_class.new }

  describe "#create" do
    let(:attributes) { Factory.structs[:staff] }

    let(:staff) do
      repo.create(
        name: attributes.name,
        email: attributes.email,
        phone: attributes.phone,
        kind: "common",
        password_digest: BCrypt::Password.create("password")
      )
    end

    it "expect create a new auction on repository" do
      expect(staff).to be_a(AuctionFunCore::Entities::Staff)
      expect(staff.name).to eq(attributes.name)
      expect(staff.email).to eq(attributes.email)
      expect(staff.phone).to eq(attributes.phone)
      expect(staff.password_digest).to be_present
      expect(staff.created_at).not_to be_blank
      expect(staff.updated_at).not_to be_blank
    end
  end

  describe "#update" do
    let(:staff) { Factory[:staff] }
    let(:new_name) { "New name" }

    it "expect update staff on repository" do
      expect { repo.update(staff.id, name: new_name) }
        .to change { repo.by_id(staff.id).name }
        .from(staff.name)
        .to(new_name)
    end
  end

  describe "#delete" do
    let!(:staff) { Factory[:staff] }

    it "expect remove staff on repository" do
      expect { repo.delete(staff.id) }
        .to change(repo, :count)
        .from(1).to(0)
    end
  end

  describe "#all" do
    let!(:staff) { Factory[:staff] }

    it "expect return all staffs" do
      expect(repo.all.size).to eq(1)
      expect(repo.all.first.id).to eq(staff.id)
    end
  end

  describe "#count" do
    context "when has not staff on repository" do
      it "expect return zero" do
        expect(repo.count).to be_zero
      end
    end

    context "when has staffs on repository" do
      let!(:auction) { Factory[:staff] }

      it "expect return total" do
        expect(repo.count).to eq(1)
      end
    end
  end

  describe "#query(conditions)" do
    let(:conditions) { {active: true} }

    it "expect add sql conditions in query" do
      expect(repo.query(conditions).dataset.sql).to include('WHERE ("active" IS TRUE)')
    end
  end

  describe "#by_id(id)" do
    context "when id is founded on repository" do
      let!(:staff) { Factory[:staff] }

      it "expect return rom object" do
        expect(repo.by_id(staff.id)).to be_a(AuctionFunCore::Entities::Staff)
      end
    end

    context "when id is not found on repository" do
      it "expect return nil" do
        expect(repo.by_id(nil)).to be_nil
      end
    end
  end

  describe "#by_id!(id)" do
    context "when id is founded on repository" do
      let!(:staff) { Factory[:staff] }

      it "expect return rom object" do
        expect(repo.by_id(staff.id)).to be_a(AuctionFunCore::Entities::Staff)
      end
    end

    context "when id is not found on repository" do
      it "expect raise exception" do
        expect { repo.by_id!(nil) }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end
end
