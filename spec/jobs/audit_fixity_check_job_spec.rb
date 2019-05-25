# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditFixityCheckJob do
  let(:package) { Fabricate(:package) }
  let(:user) { Fabricate(:user) }
  let(:email) { double(:email, deliver_now: nil) }
  let(:mailer)  { double(:mailer, failure: email) }
  let(:audit) { Fabricate(:audit) }

  subject(:event) { package.events.last }

  def run_job
    described_class.perform_now(audit: audit, package: package, user: user, storage: bag, mailer: mailer)
  end

  shared_examples_for "a fixity check job" do |outcome|
    it "records a fixity check event" do
      run_job
      expect(event.event_type).to eq("fixity check")
    end
    it "records the user that ran the fixity check" do
      run_job
      expect(event.user).to eq(user)
    end
    it "records #{outcome}" do
      run_job
      expect(event.outcome).to eq(outcome.to_s)
    end
  end

  context "with an audit" do
    let(:bag) { double(:bag, valid?: true) }

    it "records the audit in the event" do
      run_job
      expect(event.audit_id).to eq(audit.id)
    end
  end

  context "when the bag is valid" do
    let(:bag) { double(:bag, valid?: true) }

    it_behaves_like "a fixity check job", "success"

    it "does not send email" do
      expect(mailer).not_to receive(:failure)
      run_job
    end
  end

  context "when the bag is not valid" do
    let(:error) { Faker::Lorem.sentence }
    let(:bag) do
      double(:bag, valid?: false,
       errors: double("errors", full_messages: [error]))
    end

    it_behaves_like "a fixity check job", "failure"

    it "records the error" do
      run_job
      expect(event.detail).to match(error)
    end

    context "with an audit" do
      it "passes the audit to the failure mailer" do
        expect(mailer).to receive(:failure).with(emails: [audit.user.email], package: package, error: error)
        run_job
      end
    end
  end

  context "when the fixity check raises an exception" do
    let(:bag) { double(:bag) }

    before(:each) { allow(bag).to receive(:valid?).and_raise(RuntimeError) }

    it_behaves_like "a fixity check job", "failure"

    it "records the error" do
      run_job
      expect(event.detail).to match("RuntimeError")
    end
  end
end
