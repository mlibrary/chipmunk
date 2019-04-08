# frozen_string_literal: true

RSpec.describe AuditsPolicy do
  context "as an admin" do
    let(:user) { FakeUser.new(admin?: true) }

    it_allows :index?, :create?
    it_resolves :all
  end

  context "as a persisted non-admin user" do
    let(:user) { FakeUser.new(admin?: false) }

    it_disallows :index?, :create?
    it_resolves :none
  end

  it_has_base_scope(Audit.all)
end
