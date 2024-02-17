# frozen_string_literal: true

require "spec_helper"

RSpec.describe AuctionFunCore::Repos::UserContext::UserRepository, type: :repo do
  subject(:repo) { described_class.new }

  describe "#create" do
    let(:attributes) { Factory.structs[:user] }

    let(:user) do
      repo.create(
        name: attributes.name,
        email: attributes.email,
        phone: attributes.phone,
        password_digest: BCrypt::Password.create("password")
      )
    end

    it "expect create a new auction on repository" do
      expect(user).to be_a(AuctionFunCore::Entities::User)
      expect(user.name).to eq(attributes.name)
      expect(user.email).to eq(attributes.email)
      expect(user.phone).to eq(attributes.phone)
      expect(user.password_digest).to be_present
      expect(user.created_at).not_to be_blank
      expect(user.updated_at).not_to be_blank
    end
  end

  describe "#update" do
    let(:user) { Factory[:user] }
    let(:new_name) { "New name" }

    it "expect update user on repository" do
      expect { repo.update(user.id, name: new_name) }
        .to change { repo.by_id(user.id).name }
        .from(user.name)
        .to(new_name)
    end
  end

  describe "#delete" do
    let!(:user) { Factory[:user] }

    it "expect remove user on repository" do
      expect { repo.delete(user.id) }
        .to change(repo, :count)
        .from(1).to(0)
    end
  end

  describe "#all" do
    let!(:user) { Factory[:user] }

    it "expect return all users" do
      expect(repo.all.size).to eq(1)
      expect(repo.all.first.id).to eq(user.id)
    end
  end

  describe "#count" do
    context "when has not user on repository" do
      it "expect return zero" do
        expect(repo.count).to be_zero
      end
    end

    context "when has users on repository" do
      let!(:auction) { Factory[:user] }

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
      let!(:user) { Factory[:user] }

      it "expect return rom object" do
        expect(repo.by_id(user.id)).to be_a(AuctionFunCore::Entities::User)
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
      let!(:user) { Factory[:user] }

      it "expect return rom object" do
        expect(repo.by_id(user.id)).to be_a(AuctionFunCore::Entities::User)
      end
    end

    context "when id is not found on repository" do
      it "expect raise exception" do
        expect { repo.by_id!(nil) }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end
end
