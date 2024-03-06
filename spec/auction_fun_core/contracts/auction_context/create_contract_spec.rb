# frozen_string_literal: true

RSpec.describe AuctionFunCore::Contracts::AuctionContext::CreateContract, type: :contract do
  let(:min) { described_class::AUCTION_MIN_TITLE_LENGTH }
  let(:max) { described_class::AUCTION_MAX_TITLE_LENGTH }
  let(:stopwatch_min_value) { described_class::AUCTION_STOPWATCH_MIN_VALUE }
  let(:stopwatch_max_value) { described_class::AUCTION_STOPWATCH_MAX_VALUE }
  let(:kinds) { described_class::AUCTION_KINDS.join(", ") }

  describe "#call" do
    subject(:contract) { described_class.new.call(attributes) }

    context "when params are blank" do
      let(:attributes) { Dry::Core::Constants::EMPTY_HASH }

      it "expect failure with error messages" do
        expect(contract).to be_failure

        expect(contract.errors[:title]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:kind]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:started_at]).to include(I18n.t("contracts.errors.key?"))
        expect(contract.errors[:staff_id]).to include(I18n.t("contracts.errors.key?"))
      end
    end

    context "with default values" do
      let(:attributes) { {initial_bid_cents: 100} }

      it "expect minimal_bid_cents to be equal initial_bid_cents" do
        expect(contract[:minimal_bid_cents]).to eq(100)
      end
    end

    describe "#staff_id" do
      context "when staff is not found on database" do
        let(:attributes) { {staff_id: 1} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:staff_id])
            .to include(I18n.t("contracts.errors.custom.default.not_found"))
        end
      end
    end

    describe "#title" do
      let(:attributes) { {title: "abc"} }

      context "when the characters in the title are outside the allowed range" do
        it "expect failure with error messages" do
          expect(subject).to be_failure

          expect(subject.errors[:title]).to include(
            I18n.t("contracts.errors.size?.value.string.arg.range", size_left: min, size_right: max)
          )
        end
      end
    end

    describe "#kind" do
      context "when kind is outside of default list" do
        let(:attributes) { {kind: "unknown"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:kind]).to include(
            I18n.t("contracts.errors.included_in?.arg.default", list: kinds)
          )
        end
      end

      context "when kind is standard or closed and finished_at is blank" do
        let(:attributes) { {kind: "standard", started_at: 3.hours.from_now} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:finished_at]).to include(I18n.t("contracts.errors.filled?"))
        end
      end

      context "when kind is closed and finished_at is blank" do
        let(:attributes) { {kind: "closed", started_at: 3.hours.from_now} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:finished_at]).to include(I18n.t("contracts.errors.filled?"))
        end
      end
    end

    describe "#started_at" do
      context "when is less than or equal to now" do
        let(:attributes) { {started_at: 3.days.ago} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:started_at])
            .to include(I18n.t("contracts.errors.custom.default.future"))
        end
      end
    end

    describe "#finished_at" do
      context "when started_at is less than or equal to finished_at" do
        let(:same_time) { 3.hours.from_now }
        let(:attributes) { {kind: "standard", started_at: same_time, finished_at: same_time} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:finished_at])
            .to include(I18n.t("contracts.errors.custom.auction_context.create.finished_at"))
        end
      end
    end

    describe "#initial_bid_cents" do
      context "when kind is standard or closed and initial_bid_cents is blank" do
        let(:attributes) { {kind: "standard"} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:initial_bid_cents]).to include(I18n.t("contracts.errors.filled?"))
        end
      end

      context "when kind is standard or closed and initial_bid_cents is less than or equal to zero" do
        let(:attributes) { {kind: "standard", initial_bid_cents: 0} }

        it "expect failure with error messages" do
          expect(contract).to be_failure
          expect(contract.errors[:initial_bid_cents]).to include(I18n.t("contracts.errors.gt?", num: 0))
        end
      end

      context "when kind is penny and initial_bid_cents is blank" do
        let(:attributes) { {kind: "penny"} }

        it "expect failure without error message in field" do
          expect(contract).to be_failure
          expect(contract.errors[:initial_bid_cents]).to be_blank
        end
      end

      context "when kind is penny and initial_bid_cents is not zero" do
        let(:attributes) { {kind: "penny", initial_bid_cents: 1000} }

        it "expect failure with error message" do
          expect(contract).to be_failure
          expect(contract.errors[:initial_bid_cents]).to include(I18n.t("contracts.errors.eql?", left: 0))
        end
      end
    end

    it_behaves_like "validate_stopwatch_contract" do
      let(:auction) { Factory.structs[:auction, kind: :penny, initial_bid_cents: 1000] }
    end
  end
end
