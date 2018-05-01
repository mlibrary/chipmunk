require "rails_helper"

RSpec.describe AuditPresenter, type: :presenter do
  let(:audit) { Fabricate(:audit) }
  let(:presenter) { described_class.new(audit) }

  it "takes an audit as a parameter" do
    expect(presenter).not_to be_nil
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

  it "returns the number of items successfully audited so far" do
    expect(presenter.successes).to eq(0)
  end

  it "returns the number of items with failures so far" do
    expect(presenter.failures).to eq(0)
  end

  context "with an audit with three packages, one success and a failure" do
    let(:audit) { Fabricate(:audit, packages: 3) }

    before(:each) do
      2.times { Fabricate(:event, audit: audit, outcome: 'success') }
      Fabricate(:event, audit: audit, outcome: 'failure')
    end

    it "returns the number of items successfully audited so far" do
      expect(presenter.successes).to eq(2)
    end

    it "returns the number of items with failures so far" do
      expect(presenter.failures).to eq(1)
    end
  end
  
end
