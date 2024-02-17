# frozen_string_literal: true

shared_examples "validate_email_contract" do |factory_name|
  let(:factory) { Factory[factory_name] }

  context "when email is in wrong format" do
    let(:attributes) { {email: "wrongemail"} }

    it "expect failure with error messages" do
      expect(subject).to be_failure

      expect(subject.errors[:email]).to include(I18n.t("contracts.errors.custom.macro.email_format"))
    end
  end

  context "when email is already exists on database" do
    let(:attributes) { {email: factory.email} }

    it "expect failure with error messages" do
      expect(subject).to be_failure

      expect(subject.errors[:email]).to include(I18n.t("contracts.errors.custom.default.taken"))
    end
  end
end
