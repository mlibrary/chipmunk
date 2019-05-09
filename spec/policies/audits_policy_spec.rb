# frozen_string_literal: true

RSpec.describe AuditsPolicy, type: :policy  do
  context "as a user granted admin" do
    let(:user) { FakeUser.admin() }

    it_allows :index?, :new?
    it_resolves :all
  end

  context "as a user granted nothing" do
    let(:user) { FakeUser.new() }

    it_disallows :index?, :new?
    it_resolves :none
  end

  it_has_base_scope(Audit.all)
end
