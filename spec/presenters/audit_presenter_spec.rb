# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditPresenter, type: :presenter do
  let(:audit) { Fabricate(:audit) }
  let(:presenter) { described_class.new(audit) }

  it "takes an audit as a parameter" do
    expect(presenter).not_to be_nil
  end
  
  it "returns the audit's id" do
    expect(presenter.id).to eq(audit.id)
  end

  it "returns the audit's user" do
    expect(presenter.user).to eq(audit.user)
  end

  it "returns the audit's package count" do
    expect(presenter.packages).to eq(audit.packages)
  end

  it "returns the audit's creation timestamp" do
    expect(presenter.created_at).to eq(audit.created_at)
  end

  it "returns the events for packages successfully audited so far" do
    expect(presenter.successes).to be_empty
  end

  it "returns the events for packages with failures so far" do
    expect(presenter.failures).to be_empty
  end

  it "can take an expand parameter" do
    expect(described_class.new(audit, expand: true).expand?).to be(true)
  end

  context "with an audit with three packages, one success and a failure" do
    let(:audit) { Fabricate(:audit, packages: 3) }
    let!(:successes) { Array.new(2) { Fabricate(:event, audit: audit, outcome: "success") } }
    let!(:failures) { [Fabricate(:event, audit: audit, outcome: "failure")] }

    it "returns the events for packages successfully audited so far" do
      expect(presenter.successes).to contain_exactly(*successes)
    end

    it "returns the events for packages with failures so far" do
      expect(presenter.failures).to contain_exactly(*failures)
    end
  end
end
