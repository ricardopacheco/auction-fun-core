# frozen_string_literal: true

shared_examples "validate_phone_contract" do |factory_name|
  let(:factory) { Factory[factory_name] }

  context "when phone is in wrong format" do
    let(:attributes) { {phone: "12345"} }

    it "expect failure with error messages" do
      expect(subject).to be_failure

      expect(subject.errors[:phone]).to include(I18n.t("contracts.errors.custom.macro.phone_format"))
    end
  end

  context "when phone is already exists on database" do
    let(:attributes) { {phone: factory.phone} }

    it "expect failure with error messages" do
      expect(subject).to be_failure

      expect(subject.errors[:phone]).to include(I18n.t("contracts.errors.custom.default.taken"))
    end
  end
end
