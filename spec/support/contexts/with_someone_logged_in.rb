# frozen_string_literal: true

RSpec.shared_context "with someone logged in" do
  let(:user) { Fabricate(:user) }
  before(:each) { controller.fake_user(user) }
end
